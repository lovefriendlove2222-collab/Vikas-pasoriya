import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vikas pasoriya',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("vikas pasoriya"),
        actions: [IconButton(icon: Icon(Icons.lock_person), onPressed: () => _key.currentState?.openEndDrawer())],
      ),
      drawer: buildLeftDrawer(context),
      endDrawer: buildRightAdminDrawer(context),
      body: Column(
        children: [
          // डोनर टिकर (Requirement 4 & 5)
          Container(
            height: 35, color: Colors.yellowAccent,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donors').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return Text("Loading...");
                String txt = snap.data!.docs.map((d) => "${d['name']} - ₹${d['amount']}").join("  |  ");
                return MarqueeText(text: txt);
              },
            ),
          ),
          // वीडियो फीड (Requirement 3)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('videos').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snap.data!.docs.length,
                  itemBuilder: (context, i) => VideoItem(url: snap.data!.docs[i]['link']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // लेफ्ट मेनू (Requirement 8, 9, 10)
  Widget buildLeftDrawer(context) => Drawer(
    child: ListView(
      children: [
        DrawerHeader(child: Image.asset('assets/logo.png', errorBuilder: (c,e,s) => Icon(Icons.image))),
        ListTile(title: Text("पूर्णमासी कार्यक्रम"), leading: Icon(Icons.event)),
        ListTile(title: Text("रेगुलर कार्यक्रम"), leading: Icon(Icons.calendar_today)),
        ListTile(title: Text("संस्था जानकारी"), leading: Icon(Icons.info)),
        Divider(),
        ListTile(title: Text("कार्यक्रम बुकिंग"), subtitle: Text("संपर्क: एडमिन")),
        ListTile(title: Text("गुरु जी की पाठशाला टीम")),
      ],
    ),
  );

  // राइट एडमिन मेनू (Requirement 11, 14)
  Widget buildRightAdminDrawer(context) => Drawer(
    child: Column(
      children: [
        UserAccountsDrawerHeader(accountName: Text("Admin Panel"), accountEmail: Text("Secure Login")),
        ListTile(title: Text("डोनर लिस्ट (PDF)"), leading: Icon(Icons.picture_as_pdf)),
        Spacer(),
        // डेवलपर संपर्क (Requirement 14)
        ListTile(
          tileColor: Colors.grey[200],
          title: Text("डेवलपर: विवेक कौशिक"),
          subtitle: Text("+91 7206966924"),
          leading: Icon(Icons.code),
        ),
      ],
    ),
  );
}

// वीडियो प्लेयर म्यूट के साथ
class VideoItem extends StatefulWidget {
  final String url;
  VideoItem({required this.url});
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late YoutubePlayerController _ctrl;
  bool muted = true;
  @override
  void initState() {
    super.initState();
    _ctrl = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
      flags: YoutubePlayerFlags(mute: true, autoPlay: false),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          YoutubePlayer(controller: _ctrl),
          IconButton(icon: Icon(muted ? Icons.volume_off : Icons.volume_up), 
          onPressed: () => setState(() { muted = !muted; muted ? _ctrl.mute() : _ctrl.unMute(); })),
        ],
      ),
    );
  }
}

class MarqueeText extends StatelessWidget {
  final String text;
  MarqueeText({required this.text});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)));
  }
}
