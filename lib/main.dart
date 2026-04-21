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
  await Firebase.initializeApp(); // ऑनलाइन सिंक के लिए फायरबेस
  runApp(VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vikas pasoriya', // 1. बिना डेश के नाम
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
        leading: IconButton(icon: Icon(Icons.menu),这对 _scaffoldKey.currentState?.openDrawer()),
        actions: [
          IconButton(icon: Icon(Icons.admin_panel_settings), onPressed: () => _scaffoldKey.currentState?.openEndDrawer()),
        ],
      ),
      // 8, 9, 10. लेफ्ट मेनू
      drawer: buildLeftDrawer(context),
      // 11, 14. राइट एडमिन मेनू
      endDrawer: buildRightAdminDrawer(context),
      body: Column(
        children: [
          // 4, 5. डोनर टिकर (चलता हुआ नाम)
          Container(
            height: 35,
            color: Colors.amber[100],
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donations').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: Text("Loading Donors..."));
                String tickerText = snapshot.data!.docs.map((d) => 
                  "${d['name']} (${d['village']}) ने ${d['amount']} रुपये दान दिए - ${d['time']}").join("  |  ");
                return MarqueeWidget(text: tickerText); // यह नाम चलाएगा
              },
            ),
          ),

          // 3, 5. वीडियो डैशबोर्ड (म्यूट/अनम्यूट के साथ)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('videos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var v = snapshot.data!.docs[index];
                    return VideoCard(url: v['link']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- लेफ्ट मेनू (Requirements 8, 9, 10) ---
  Widget buildLeftDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Image.network("YOUR_LOGO_URL")), // 2. लोगो
          ListTile(title: Text("पूर्णमासी कार्यक्रम"), onTap: () {}),
          ListTile(title: Text("रेगुलर कार्यक्रम"), onTap: () {}),
          ListTile(title: Text("संस्था की पूरी जानकारी"), onTap: () {}),
          Divider(),
          ListTile(title: Text("कार्यक्रम बुकिंग (संपर्क)"), subtitle: Text("एडमिन नंबर यहाँ आएगा"), onTap: () {}),
          ListTile(title: Text("गुरु जी की पाठशाला टीम संपर्क"), onTap: () {}),
        ],
      ),
    );
  }

  // --- राइट एडमिन मेनू (Requirements 11, 14) ---
  Widget buildRightAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(accountName: Text("एडमिन पैनल"), accountEmail: Text("सुरक्षित लॉगिन")),
          ListTile(leading: Icon(Icons.add_link), title: Text("वीडियो लिंक डालें"), onTap: () {}),
          ListTile(leading: Icon(Icons.payment), title: Text("UPI आईडी बदलें"), onTap: () {}),
          ListTile(leading: Icon(Icons.list_alt), title: Text("डोनर लिस्ट (PDF)"), onTap: () {}),
          Divider(),
          // 14. डेवलपर संपर्क
          ListTile(
            tileColor: Colors.grey[200],
            title: Text("एप डेवलोपर सम्पर्क"),
            subtitle: Text("विवेक कौशिक\n+91 7206966924"),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}

// 3. वीडियो प्लेयर म्यूट बटन के साथ
class VideoCard extends StatefulWidget {
  final String url;
  VideoCard({required this.url});
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
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Mute/Unmute"),
              IconButton(
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                onPressed: () {
                  setState(() {
                    isMuted = !isMuted;
                    isMuted ? _controller.mute() : _controller.unMute();
                  });
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

// टिकर (चलता हुआ नाम) के लिए सिंपल विजिट
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 10),
        curve: Curves.linear,
      ).then((_) {
        _scrollController.jumpTo(0);
        _startScrolling();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      children: [Text(widget.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],
    );
  }
}
