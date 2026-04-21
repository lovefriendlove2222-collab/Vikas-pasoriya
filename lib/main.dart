import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
      drawer: buildLeftDrawer(),
      endDrawer: buildRightAdminDrawer(),
      body: Column(
        children: [
          // डोनर टिकर
          Container(
            height: 40, color: Colors.yellowAccent,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donors').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return Center(child: Text("Loading..."));
                String txt = snap.data!.docs.map((d) => "${d['name']} - ₹${d['amount']}").join("  |  ");
                return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Center(child: Text(txt, style: TextStyle(fontWeight: FontWeight.bold))));
              },
            ),
          ),
          // वीडियो लिस्ट
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

  Widget buildLeftDrawer() => Drawer(child: ListView(children: [
    DrawerHeader(child: Center(child: Text("गुरु जी की पाठशाला"))),
    ListTile(title: Text("पूर्णमासी कार्यक्रम")),
    ListTile(title: Text("संस्था जानकारी")),
  ]));

  Widget buildRightAdminDrawer() => Drawer(child: Column(children: [
    UserAccountsDrawerHeader(accountName: Text("Admin"), accountEmail: Text("Secure")),
    ListTile(title: Text("UPI अपडेट")),
    Spacer(),
    ListTile(title: Text("डेवलपर: विवेक कौशिक"), subtitle: Text("+91 7206966924"), tileColor: Colors.grey[200]),
  ]));
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
    return Card(child: Column(children: [
      YoutubePlayer(controller: _ctrl),
      IconButton(icon: Icon(muted ? Icons.volume_off : Icons.volume_up), 
      onPressed: () => setState(() { muted = !muted; muted ? _ctrl.mute() : _ctrl.unMute(); })),
    ]));
  }
}
