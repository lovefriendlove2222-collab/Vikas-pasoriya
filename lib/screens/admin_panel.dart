import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🚩 सुपर एडमिन कंट्रोल 🚩"),
        backgroundColor: Colors.orange[900],
      ),
      body: GridView.count(
        padding: EdgeInsets.all(15),
        crossAxisCount: 2, // दो-दो के कॉलम में बटन दिखेंगे
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          adminCard(context, "यूजर मैनेजमेंट", Icons.group, Colors.blue, () {
            // यहाँ से आप यूजर को ब्लॉक/रिमूव कर पाएंगे
          }),
          adminCard(context, "UPI/QR बदलें", Icons.qr_code_scanner, Colors.green, () {
            // यहाँ से QR कोड की फोटो अपडेट होगी
          }),
          adminCard(context, "संस्था जोड़ें/बदलें", Icons.account_balance, Colors.brown, () {
            // संस्थाओं की जानकारी यहाँ से मैनेज होगी
          }),
          adminCard(context, "प्रोग्राम अपडेट", Icons.event, Colors.deepOrange, () {
            // आगामी प्रोग्राम की लोकेशन और डेट
          }),
          adminCard(context, "डोनेशन योजना", Icons.volunteer_activism, Colors.red, () {
            // नई डोनेशन स्कीम बनाना
          }),
          adminCard(context, "आईडी कार्ड/पद", Icons.badge, Colors.purple, () {
            // यहाँ से आप पद सेलेक्ट करके आईडी देंगे
          }),
        ],
      ),
    );
  }

  Widget adminCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
