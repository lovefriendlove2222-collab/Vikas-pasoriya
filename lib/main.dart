import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(VikasApp());
}

class VikasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vikas Pasoriya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("विकास पासोरिया - लोकगायक"),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // बैनर फोटो (बाद में अपनी फोटो डाल सकते हैं)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black12,
              child: Center(child: Icon(Icons.music_note, size: 100, color: Colors.orange)),
            ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Text("मेरे लाइव स्टेज शो", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),

            // यूट्यूब वीडियो कार्ड
            VideoCard(videoId: "dQw4w9WgXcQ"), // यहाँ अपनी रागनी का ID बदलें
            VideoCard(videoId: "videoId2"), 
          ],
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final String videoId;
  VideoCard({required this.videoId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(autoPlay: false, mute: false),
        ),
      ),
    );
  }
}
