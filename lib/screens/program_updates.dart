import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramUpdate extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app_bar: AppBar(title: Text("नया प्रोग्राम डालें"), backgroundColor: Colors.orange[900]),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "प्रोग्राम का नाम (जैसे: रागनी नाईट)")),
            TextField(controller: dateController, decoration: InputDecoration(labelText: "तारीख और समय")),
            TextField(controller: locationController, decoration: InputDecoration(labelText: "लोकेशन (गाँव/शहर)")),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900]),
              onPressed: () {
                FirebaseFirestore.instance.collection('Programs').add({
                  'title': titleController.text,
                  'date': dateController.text,
                  'location': locationController.text,
                });
                Navigator.pop(context);
              },
              child: Text("प्रोग्राम लाइव करें", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
