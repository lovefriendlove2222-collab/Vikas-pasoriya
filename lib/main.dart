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
  await Firebase.initializeApp(); // ऑनलाइन डेटा सिंक के लिए
  runApp(VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vikas pasoriya', // शर्त 1: बिना डेश के नाम
      theme: ThemeData(primaryColor: Colors.orange, primarySwatch: Colors.orange),
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
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(), // शर्त 11
          ),
        ],
      ),
      
      // --- लेफ्ट मेनू (संस्था और कार्यक्रम जानकारी) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Column(
                children: [
                  CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/logo.png')), // शर्त 2: लोगो
                  SizedBox(height: 10),
                  Text("गुरु जी की पाठशाला", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(leading: Icon(Icons.event), title: Text("पूर्णमासी कार्यक्रम"), onTap: () {}), // शर्त 8
            ListTile(leading: Icon(Icons.calendar_today), title: Text("रेगुलर कार्यक्रम"), onTap: () {}), // शर्त 8
            ListTile(leading: Icon(Icons.info), title: Text("संस्था की पूरी जानकारी"), onTap: () {}), // शर्त 9
            Divider(),
            ListTile(leading: Icon(Icons.phone), title: Text("कार्यक्रम बुकिंग"), subtitle: Text("संपर्क सूत्र"), onTap: () {}), // शर्त 10
            ListTile(leading: Icon(Icons.group), title: Text("टीम संपर्क"), onTap: () {}), // शर्त 10
          ],
        ),
      ),

      // --- राइट मेनू (एडमिन पैनल और डेवलपर संपर्क) ---
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("एडमिन कंट्रोल"),
              accountEmail: Text("पासवर्ड सुरक्षित लॉगिन"),
              currentAccountPicture: Icon(Icons.security, color: Colors.white, size: 50),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(leading: Icon(Icons.add_link), title: Text("वीडियो लिंक जोड़ें"), onTap: () {}),
                  ListTile(leading: Icon(Icons.payment), title: Text("UPI आईडी बदलें"), onTap: () {}),
                  ListTile(leading: Icon(Icons.picture_as_pdf), title: Text("डोनर लिस्ट निकालें"), onTap: () {}),
                ],
              ),
            ),
            // शर्त 14: डेवलपर संपर्क
            Container(
              color: Colors.grey[200],
              child: ListTile(
                title: Text("एप डेवलोपर सम्पर्क", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("विवेक कौशिक\n+91 7206966924"),
                leading: Icon(Icons.developer_mode, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // शर्त 4, 5: डोनर टिकर (नाम और राशि डैशबोर्ड पर चलेगी)
          Container(
            height: 40,
            width: double.infinity,
            color: Colors.yellowAccent,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donations').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: Text("Loading Donors..."));
                String tickerText = snapshot.data!.docs.map((d) => 
                  "${d['name']} (${d['village']}) - ₹${d['amount']} | ").join(" ");
                return MarqueeScroll(text: tickerText); // नाम चलाने वाला विजेट
              },
            ),
          ),

          // शर्त 3, 5: वीडियो डैशबोर्ड (हजारों वीडियो लिंक सिंक होंगे)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('videos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var videoData = snapshot.data!.docs[index];
                    return VideoPlayerCard(url: videoData['link']); // म्यूट/अनम्यूट के साथ
                  },
                );
              },
            ),
          ),
          
          // शर्त 4, 6: डोनेशन और मंथली डोनर बटन
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: Text("डोनेशन दें")),
                ElevatedButton(onPressed: () {}, child: Text("मंथली डोनर बनें")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- वीडियो प्लेयर विजेट (शर्त 3 के अनुसार म्यूट फीचर के साथ) ---
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
      margin: EdgeInsets.all(10),
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

// --- डोनर नाम चलाने वाला विजेट (टिकर) ---
class MarqueeScroll extends StatefulWidget {
  final String text;
  MarqueeScroll({required this.text});
  @override
  _MarqueeScrollState createState() => _MarqueeScrollState();
}

class _MarqueeScrollState extends State<MarqueeScroll> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(_scrollController.offset + 2, 
          duration: Duration(milliseconds: 50), curve: Curves.linear);
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      children: [Text(widget.text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red))],
    );
  }
}
