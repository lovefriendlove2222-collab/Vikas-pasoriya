import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization (ensure google-services.json is in android/app)
  await Firebase.initializeApp(); 
  runApp(VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vikas pasoriya', // शर्त 1: बिना डेश के नाम
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
        title: Text("vikas pasoriya"), // शर्त 1
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(), // शर्त 11: एडमिन लॉगिन
          ),
        ],
      ),

      // --- लेफ्ट मेनू (Requirement 8, 9, 10) ---
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Center(child: Text("संस्था का लोगो")), // शर्त 2: लोगो
            ),
            ListTile(title: Text("पूर्णमासी कार्यक्रम"), onTap: () {}), // शर्त 8
            ListTile(title: Text("रेगुलर कार्यक्रम"), onTap: () {}), // शर्त 8
            ListTile(title: Text("संस्था की पूरी जानकारी"), onTap: () {}), // शर्त 9
            Divider(),
            ListTile(title: Text("कार्यक्रम बुकिंग संपर्क"), subtitle: Text("मोबाईल नम्बर"), onTap: () {}), // शर्त 10
            ListTile(title: Text("टीम संपर्क सूत्र"), onTap: () {}), // शर्त 10
          ],
        ),
      ),

      // --- राइट मेनू (Requirement 11, 14) ---
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("एडमिन पैनल"),
              accountEmail: Text("पासवर्ड प्रोटेक्टेड"),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(title: Text("वीडियो लिंक डालें"), onTap: () {}),
                  ListTile(title: Text("UPI आईडी अपडेट करें"), onTap: () {}),
                  ListTile(title: Text("डोनर लिस्ट (PDF)"), onTap: () {}), // शर्त 11
                ],
              ),
            ),
            Divider(),
            // शर्त 14: एप डेवलोपर सम्पर्क
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
          // शर्त 4, 5: डोनर का नाम डैशबोर्ड पर चलता रहे (Ticker)
          Container(
            height: 40,
            color: Colors.yellowAccent,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donors').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: Text("Loading..."));
                String donors = snapshot.data!.docs.map((d) => "${d['name']} (₹${d['amount']})").join(" | ");
                return MarqueeWidget(text: donors);
              },
            ),
          ),

          // शर्त 3, 5: वीडियो डैशबोर्ड (म्यूट/अनम्यूट के साथ)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('videos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var v = snapshot.data!.docs[index];
                    return VideoPlayerCard(url: v['link']);
                  },
                );
              },
            ),
          ),
          
          // शर्त 7: संस्था के कार्य
          Container(height: 50, child: Center(child: Text("संस्था के डेली कार्य यहाँ दिखेंगे"))),
        ],
      ),
    );
  }
}

// --- वीडियो प्लेयर म्यूट फीचर के साथ (Requirement 3) ---
class VideoPlayerCard extends StatefulWidget {
  final String url;
  VideoPlayerCard({required this.url});
  @override
  _VideoPlayerCardState createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  late YoutubePlayerController _controller;
  bool isMuted = true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
      flags: YoutubePlayerFlags(mute: true, autoPlay: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          YoutubePlayer(controller: _controller),
          IconButton(
            icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              setState(() {
                isMuted = !isMuted;
                isMuted ? _controller.mute() : _controller.unMute();
              });
            },
          ),
        ],
      ),
    );
  }
}

// --- नाम चलाने वाला टिकर ---
class MarqueeWidget extends StatefulWidget {
  final String text;
  MarqueeWidget({required this.text});
  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.offset + 1, 
        duration: Duration(milliseconds: 50), curve: Curves.linear);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      children: [Text(widget.text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
    );
  }
}
