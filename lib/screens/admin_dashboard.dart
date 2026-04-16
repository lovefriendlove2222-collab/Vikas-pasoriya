import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vikas Pasoria Admin Panel"), backgroundColor: Colors.redAccent),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildAdminCard(context, "Approve Members", Icons.person_add, () => _showApprovalList(context)),
          _buildAdminCard(context, "Add New Features", Icons.add_circle, () => _addNewOption(context)),
          _buildAdminCard(context, "Manage Notifications", Icons.notifications, () {}),
          _buildAdminCard(context, "User Statistics", Icons.bar_chart, () {}),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  // भविष्य में 100+ ऑप्शन ऐड करने वाला डायनामिक सिस्टम
  void _addNewOption(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Dynamic Option"),
        content: TextField(controller: nameController, decoration: InputDecoration(hintText: "Option Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('app_settings').add({
                'feature_name': nameController.text,
                'is_enabled': true,
                'created_at': Timestamp.now(),
              });
              Navigator.pop(context);
            },
            child: Text("Add Now"),
          )
        ],
      ),
    );
  }

  void _showApprovalList(BuildContext context) {
    // यहाँ आप उन मेंबर्स की लिस्ट देख सकते हैं जिन्होंने रजिस्टर किया है
  }
}
