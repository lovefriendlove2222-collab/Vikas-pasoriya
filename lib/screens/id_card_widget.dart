import 'package:flutter/material.dart';

class UserIDCard extends StatelessWidget {
  final String name;
  final String village;
  final String post; // पद (जैसे: सदस्य, अध्यक्ष)

  UserIDCard({required this.name, required this.village, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.orange[900]!, width: 2)),
      child: Container(
        width: 300,
        height: 180,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text("विकास पासोरिया ऑफिसियल टीम", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
            Divider(color: Colors.orange[900]),
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.orange[800], child: Icon(Icons.person, color: Colors.white)),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("नाम: $name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("गाँव: $village"),
                    Text("पद: $post", style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
