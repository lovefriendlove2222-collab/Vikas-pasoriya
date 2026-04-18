import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: VikasAIDashboard()));
}

class VikasAIDashboard extends StatelessWidget {
  const VikasAIDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // डार्क AI लुक
      appBar: AppBar(
        title: FadeInDown(child: const Text('विकास पासोरिया AI डैशबोर्ड')),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 10,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('settings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          String youtubeUrl = data['youtube'] ?? "";

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // AI प्रोफाइल सेक्शन
                  ZoomIn(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.deepOrange, Colors.purple]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(Icons.psychology, size: 100, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // AI ऑप्शन बटन
                  FadeInLeft(
                    child: ListTile(
                      tileColor: Colors.white10,
                      leading: const Icon(Icons.auto_awesome, color: Colors.cyanAccent),
                      title: const Text("AI म्यूजिक जनरेटर (Beta)", style: TextStyle(color: Colors.white)),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 15),
                  // यूट्यूब बटन
                  FadeInRight(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      onPressed: () => launchUrl(Uri.parse(youtubeUrl)),
                      icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                      label: const Text("OFFICIAL YOUTUBE", style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
