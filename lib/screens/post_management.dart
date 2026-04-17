import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostManagement extends StatefulWidget {
  @override
  _PostManagementState createState() => _PostManagementState();
}

class _PostManagementState extends State<PostManagement> {
  final TextEditingController captionController = TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("नई पोस्ट साझा करें"), backgroundColor: Colors.orange[900]),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            // फोटो अपलोड का बटन (डिज़ाइन के लिए)
            InkWell(
              onTap: () { /* इमेज पिकर लॉजिक */ },
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.add_a_photo, size: 50, color: Colors.orange), Text("फोटो चुनें")],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(controller: captionController, decoration: InputDecoration(labelText: "कैप्शन लिखें (जैसे: आज का प्रोग्राम...)", border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: videoLinkController, decoration: InputDecoration(labelText: "यूट्यूब वीडियो लिंक (यदि हो तो)", border: OutlineInputBorder())),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900]),
                onPressed: () {
                  // डेटाबेस में पोस्ट सेव करना
                  FirebaseFirestore.instance.collection('Posts').add({
                    'caption': captionController.text,
                    'videoUrl': videoLinkController.text,
                    'date': DateTime.now(),
                  });
                  Navigator.pop(context);
                },
                child: Text("लाइव पोस्ट करें", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
