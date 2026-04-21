import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ऑनलाइन सिंक के लिए जरूरी
  runApp(VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vikas pasoriya', // बिना डेश के नाम
      theme: ThemeData(primarySwatch: Colors.orange),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("vikas pasoriya"),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      // --- लेफ्ट मेनू (संस्था की जानकारी और कार्यक्रम) ---
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Center(child: Text("संस्था लोगो यहाँ"))), // लोगो [Req 2]
            ListTile(title: Text("पूर्णमासी कार्यक्रम"), onTap: () {}), // [Req 8]
            ListTile(title: Text("रेगुलर कार्यक्रम"), onTap: () {}), // [Req 8]
            ListTile(title: Text("संस्था की पूरी जानकारी"), onTap: () {}), // [Req 9]
            Divider(),
            ListTile(title: Text("कार्यक्रम बुकिंग (मोबाईल)"), onTap: () {}), // [Req 10]
            ListTile(title: Text("गुरु जी की पाठशाला टीम संपर्क"), onTap: () {}), // [Req 10]
          ],
        ),
      ),
      // --- राइट मेनू (एडमिन और डेवलपर संपर्क) ---
      endDrawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(accountName: Text("एडमिन पैनल"), accountEmail: Text("लॉगिन करें")),
            ListTile(title: Text("UPI आईडी अपडेट करें"), onTap: () {}),
            ListTile(title: Text("वीडियो लिंक डालें"), onTap: () {}),
            ListTile(title: Text("डोनर लिस्ट (PDF)"), onTap: () {}),
            Divider(),
            // [Req 14] डेवलपर संपर्क
            ListTile(
              tileColor: Colors.orange[50],
              title: Text("एप डेवलोपर सम्पर्क"),
              subtitle: Text("विवेक कौशिक\n+91 7206966924"),
              leading: Icon(Icons.code),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // [Req 4, 5] डोनर का नाम डैशबोर्ड पर चलता रहे
          Container(
            height: 35,
            color: Colors.yellow[700],
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donors').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: Text("Loading..."));
                String donorData = snapshot.data!.docs
                    .map((d) => "${d['name']} (${d['village']}) - ₹${d['amount']}")
                    .join("  |  ");
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(donorData, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          // [Req 3, 5] वीडियो डैशबोर्ड (म्यूट के साथ)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('videos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var v = snapshot.data!.docs[index];
                    return VideoCard(videoUrl: v['url']);
                  },
                );
              },
            ),
          ),
          // [Req 7] संस्था के डेली काम (Admin Post)
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Text("संस्था के आज के कार्य यहाँ दिखेंगे"),
          ),
        ],
      ),
    );
  }
}

// वीडियो प्लेयर क्लास (म्यूट/अनम्यूट बटन के साथ)
class VideoCard extends StatefulWidget {
  final String videoUrl;
  VideoCard({required this.videoUrl});
  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late YoutubePlayerController _controller;
  bool isMuted = true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: YoutubePlayerFlags(mute: true, autoPlay: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          YoutubePlayer(controller: _controller),
          TextButton.icon(
            onPressed: () {
              setState(() {
                isMuted = !isMuted;
                isMuted ? _controller.mute() : _controller.unMute();
              });
            },
            icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
            label: Text(isMuted ? "Unmute करें" : "Mute करें"),
          )
        ],
      ),
    );
  }
}
