import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: VikasApp()));
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('विकास पासोरिया ऑफिसियल'), backgroundColor: Colors.deepOrange),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('settings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          return Center(
            child: ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(data['youtube'])),
              child: const Text("यूट्यूब चैनल देखें"),
            ),
          );
        },
      ),
    );
  }
}
