import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vikas Pasoria Admin"),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildCard(context, "Approve Members", Icons.person_add),
          _buildCard(context, "Add 100+ New Options", Icons.add_to_photos),
          _buildCard(context, "Send Notification", Icons.send),
          _buildCard(context, "App Settings", Icons.settings),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          // भविष्य के फीचर्स यहाँ जुड़ेंगे
        },
      ),
    );
  }
}
