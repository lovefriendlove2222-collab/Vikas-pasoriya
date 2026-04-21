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
  // पक्का करें कि google-services.json फ़ाइल android/app/ में मौजूद है
  await Firebase.initializeApp(); 
  runApp(VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vikas pasoriya', // शर्त 1: बिना डेश के नाम
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("vikas pasoriya", style: TextStyle(fontWeight: FontWeight.bold)), // शर्त 1
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(), // शर्त 11: एडमिन लॉगिन
          ),
        ],
      ),

      // --- लेफ्ट मेनू (Requirement 8, 9, 10) ---
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Center(child: Text("Logo: गुरु जी की पाठशाला", style: TextStyle(color: Colors.white, fontSize: 20))), // शर्त 2
            ),
            ListTile(leading: Icon(Icons.star), title: Text("पूर्णमासी कार्यक्रम"), onTap: () {}), // शर्त 8
            ListTile(leading: Icon(Icons.calendar_month), title: Text("रेगुलर कार्यक्रम"), onTap: () {}), // शर्त 8
            ListTile(leading: Icon(Icons.description), title: Text("संस्था की पूरी जानकारी"), onTap: () {}), // शर्त 9
            Divider(),
            ListTile(leading: Icon(Icons.call), title: Text("कार्यक्रम बुकिंग संपर्क"), subtitle: Text("मोबाईल: एडमिन नंबर"), onTap: () {}), // शर्त 10
            ListTile(leading: Icon(Icons.groups), title: Text("टीम संपर्क सूत्र"), onTap: () {}), // शर्त 10
          ],
        ),
      ),

      // --- राइट मेनू (Requirement 11, 14) ---
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("एडमिन कंट्रोल"),
              accountEmail: Text("सिर्फ अधिकृत व्यक्ति के लिए"),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.lock)),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(leading: Icon(Icons.video_call), title: Text("वीडियो लिंक डालें"), onTap: () {}),
                  ListTile(leading: Icon(Icons.account_balance_wallet), title: Text("UPI आईडी अपडेट करें"), onTap: () {}),
                  ListTile(leading: Icon(Icons.download), title: Text("डोनर लिस्ट (PDF)"), onTap: () {}),
                ],
              ),
            ),
            // शर्त 14: एप डेवलोपर सम्पर्क
            Container(
              color: Colors.orange[50],
              child: ListTile(
                title: Text("एप डेवलोपर सम्पर्क", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("विवेक कौशिक\n+91 7206966924"),
                leading: Icon(Icons.contact_support, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // शर्त 4, 5: डोनर टिकर (डैशबोर्ड पर डोनर का नाम चलेगा)
          Container(
            height: 40,
            color: Colors.yellowAccent,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donors').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: Text("Loading Donors..."));
                String ticker = snapshot.data!.docs.map((d) => "${d['name']} (${d['village']}) ने ₹${d['amount']} दान किए").join("  |  ");
                return MarqueeWidget(text: ticker);
              },
            ),
          ),

          // शर्त 3, 5: वीडियो डैशबोर्ड (हजारों वीडियो लिंक म्यूट के साथ चलेंगे)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('videos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var videoData = snapshot.data!.docs[index];
                    return CustomVideoCard(videoUrl: videoData['link']); // म्यूट/अनम्यूट फीचर यहाँ है
                  },
                );
              },
            ),
          ),

          // शर्त 4: डोनेशन और मंथली डोनर मेनू
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: Text("डोनेशन (UPI)")),
                ElevatedButton(onPressed: () {}, child: Text("मंथली डोनर")),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- शर्त 3: वीडियो म्यूट/अनम्यूट फीचर वाली क्लास ---
class CustomVideoCard extends StatefulWidget {
  final String videoUrl;
  CustomVideoCard({required this.videoUrl});
  @override
  _CustomVideoCardState createState() => _CustomVideoCardState();
}

class _CustomVideoCardState extends State<CustomVideoCard> {
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
      elevation: 5,
      margin: EdgeInsets.all(12),
      child: Column(
        children: [
          YoutubePlayer(controller: _controller),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isMuted ? "आवाज़ बंद है" : "आवाज़ चालू है"),
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
          )
        ],
      ),
    );
  }
}

// --- नाम चलाने वाला विजेट (Marquee) ---
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
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(widget.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        )
      ],
    );
  }
}
