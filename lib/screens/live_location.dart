import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationShare extends StatelessWidget {
  final String mapLink = "https://maps.google.com/?q="; // इसमें एडमिन पैनल से लिंक आएगा

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.location_on, color: Colors.red, size: 40),
        title: Text("मेरी वर्तमान लोकेशन", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("यहाँ क्लिक करके सीधे प्रोग्राम स्थल पर पहुँचें"),
        trailing: ElevatedButton(
          onPressed: () async {
            if (await canLaunch(mapLink)) await launch(mapLink);
          },
          child: Text("रास्ता देखें"),
        ),
      ),
    );
  }
}
