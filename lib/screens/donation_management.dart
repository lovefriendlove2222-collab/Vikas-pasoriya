import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationManagement extends StatefulWidget {
  @override
  _DonationManagementState createState() => _DonationManagementState();
}

class _DonationManagementState extends State<DonationManagement> {
  TextEditingController upiController = TextEditingController();
  TextEditingController schemeNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("डोनेशन एवं रसीद सेटिंग"), backgroundColor: Colors.orange[900]),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. UPI एवं QR सेटिंग", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: upiController,
              decoration: InputDecoration(labelText: "अपनी UPI ID डालें (e.g. vikas@upi)", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () { /* यहाँ QR इमेज अपलोड का कोड आएगा */ },
              icon: Icon(Icons.upload_file),
              label: Text("नया QR कोड फोटो अपलोड करें"),
            ),
            Divider(height: 40),
            Text("2. नई डोनेशन योजना बनाएँ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: schemeNameController,
              decoration: InputDecoration(labelText: "योजना का नाम (जैसे: मंदिर निर्माण, गोशाला)", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900]),
                onPressed: () {
                  // योजना सेव करने का लॉजिक
                },
                child: Text("योजना चालू करें", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
