import 'package:flutter/material.dart';

void main() => runApp(VikasMahashaktiApp());

class VikasMahashaktiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, scaffoldBackgroundColor: Color(0xFFFFF3E0)),
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("एडमिन कंट्रोल पैनल"),
        backgroundColor: Colors.orange[900],
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(15),
        children: [
          _menuItem(context, Icons.receipt_long, "रशीद/डोनेशन", DonationPage()),
          _menuItem(context, Icons.event_note, "प्रोग्राम अपडेट", AdminActionPage("प्रोग्राम")),
          _menuItem(context, Icons.business, "संस्था जानकारी", AdminActionPage("संस्था")),
          _menuItem(context, Icons.qr_code_2, "UPI/QR सेटिंग", AdminActionPage("UPI/QR")),
          _menuItem(context, Icons.badge, "ID कार्ड मेकर", IDCardMaker()),
          _menuItem(context, Icons.post_add, "फोटो/वीडियो पोस्ट", AdminActionPage("पोस्ट")),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, Widget page) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.orange[900]),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- १. ID कार्ड मेकर (User ID & Designation) ---
class IDCardMaker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ID कार्ड जनरेटर")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "यूजर का नाम")),
            TextField(decoration: InputDecoration(labelText: "पद (जैसे: अध्यक्ष, सदस्य)")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("ID कार्ड बणाओ")),
            // यहाँ एक भगवा आईडी कार्ड का फ्रेम दिखेगा
          ],
        ),
      ),
    );
  }
}

// --- २. एडमिन एडिटिंग पेज (संस्था, UPI, प्रोग्राम) ---
class AdminActionPage extends StatelessWidget {
  final String title;
  AdminActionPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$title अपडेट करें")),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                maxLines: 5,
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: "$title की जानकारी यहाँ लिखें..."),
              ),
            ),
            ElevatedButton(onPressed: () {}, child: Text("सेव करें")),
          ],
        ),
      ),
    );
  }
}

// --- ३. डोनेशन/रशीद पेज ---
class DonationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("डोनेशन योजनाएं")),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
      body: Center(child: Text("यहाँ से तू नई योजनाएं बणा सके सै")),
    );
  }
}
