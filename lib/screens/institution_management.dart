import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstitutionManagement extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController workController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app_bar: AppBar(title: Text("संस्था जानकारी अपडेट"), backgroundColor: Colors.orange[900]),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "संस्था का नाम")),
            SizedBox(height: 10),
            TextField(controller: workController, maxLines: 3, decoration: InputDecoration(labelText: "संस्था क्या काम करती है?")),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900]),
              onPressed: () {
                // Firebase में संस्था सेव करने का लॉजिक
                FirebaseFirestore.instance.collection('Institutions').add({
                  'name': nameController.text,
                  'description': workController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              },
              child: Text("संस्था जोड़ें", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
