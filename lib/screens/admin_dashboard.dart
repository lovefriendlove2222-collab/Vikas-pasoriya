import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel"), backgroundColor: Colors.red),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _adminTile(context, "Approve New Members", Icons.verified),
          _adminTile(context, "Add New Feature (100+)", Icons.add_circle),
          _adminTile(context, "Send App Update Notification", Icons.notification_important),
          _adminTile(context, "Manage Songs & Content", Icons.music_note),
        ],
      ),
    );
  }

  Widget _adminTile(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Setting up $title...")));
        },
      ),
    );
  }
}
