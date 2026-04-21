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
        actions: [IconButton(icon: Icon(Icons.security), onPressed: () => _key.currentState?.openEndDrawer())],
      ),
      drawer: buildLeftDrawer(context),
      endDrawer: buildRightAdminDrawer(context),
      body: Column(
        children: [
          // शर्त 4 & 5: डोनर टिकर
          Container(
            height: 35, color: Colors.yellowAccent,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donors').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return Text("Loading Donors...");
                String txt = snap.data!.docs.map((d) => "${d['name']} - ₹${d['amount']}").join("  |  ");
                return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Center(child: Text(txt, style: TextStyle(fontWeight: FontWeight.bold))));
              },
            ),
          ),
          // शर्त 3: वीडियो म्यूट बटन के साथ
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

  Widget buildLeftDrawer(context) => Drawer(
    child: ListView(
      children: [
        DrawerHeader(child: Center(child: Text("Logo: गुरु जी की पाठशाला"))),
        ListTile(title: Text("पूर्णमासी कार्यक्रम"), leading: Icon(Icons.star)),
        ListTile(title: Text("रेगुलर कार्यक्रम"), leading: Icon(Icons.calendar_today)),
        ListTile(title: Text("संस्था की पूरी जानकारी"), leading: Icon(Icons.info)),
        Divider(),
        ListTile(title: Text("कार्यक्रम बुकिंग"), subtitle: Text("संपर्क: एडमिन")),
        ListTile(title: Text("टीम संपर्क सूत्र")),
      ],
    ),
  );

  Widget buildRightAdminDrawer(context) => Drawer(
    child: Column(
      children: [
        UserAccountsDrawerHeader(accountName: Text("एडमिन लॉगिन"), accountEmail: Text("पासवर्ड प्रोटेक्टेड")),
        ListTile(title: Text("UPI आईडी अपडेट"), leading: Icon(Icons.payment)),
        ListTile(title: Text("डोनर लिस्ट (PDF)"), leading: Icon(Icons.picture_as_pdf)),
        Spacer(),
        // शर्त 14: डेवलपर संपर्क
        Container(
          color: Colors.grey[200],
          child: ListTile(
            title: Text("डेवलपर: विवेक कौशिक"),
            subtitle: Text("+91 7206966924"),
            leading: Icon(Icons.code),
          ),
        ),
      ],
    ),
  );
}

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
