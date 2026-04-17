import 'package:flutter/material.dart';

class ContactColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app_bar: AppBar(title: Text("सम्पर्क सूत्र"), backgroundColor: Colors.orange[900]),
      body: ListView(
        children: [
          contactTile("मुख्य कार्यालय", "+91 XXXXXXXXXX", Icons.business),
          contactTile("प्रोग्राम बुकिंग", "+91 XXXXXXXXXX", Icons.call),
          contactTile("व्हाट्सएप सहायता", "+91 XXXXXXXXXX", Icons.chat),
        ],
      ),
    );
  }

  Widget contactTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange[900]),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.phone_forwarded, color: Colors.green),
    );
  }
}
