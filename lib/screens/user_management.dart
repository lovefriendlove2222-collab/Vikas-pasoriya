import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagement extends StatefulWidget {
  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("यूजर कंट्रोल पैनल"),
        backgroundColor: Colors.orange[900],
      ),
      body: Column(
        children: [
          // सर्च बार
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "नाम या मोबाइल से ढूंढें...",
                prefixIcon: Icon(Icons.search, color: Colors.orange[900]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                
                var users = snapshot.data!.docs.where((doc) => 
                  doc['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                  doc['phone'].contains(searchQuery)).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.orange[800], child: Icon(Icons.person, color: Colors.white)),
                        title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${user['village']} | पद: ${user['post']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // पद बदलने का बटन
                            IconButton(
                              icon: Icon(Icons.badge, color: Colors.blue),
                              onPressed: () => _showPostDialog(user.id, user['name']),
                            ),
                            // ब्लॉक करने का बटन
                            IconButton(
                              icon: Icon(Icons.block, color: Colors.red),
                              onPressed: () => _confirmBlock(user.id, user['name']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // पद चुनने के लिए डायलॉग बॉक्स
  void _showPostDialog(String userId, String name) {
    String selectedPost = "सदस्य";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$name का पद चुनें"),
        content: DropdownButtonFormField<String>(
          value: selectedPost,
          items: ["सदस्य", "जिला अध्यक्ष", "प्रदेश अध्यक्ष", "महामंत्री", "मीडिया प्रभारी"]
              .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (val) => selectedPost = val!,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("कैंसिल")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('Users').doc(userId).update({'post': selectedPost});
              Navigator.pop(context);
            },
            child: Text("अपडेट करें"),
          ),
        ],
      ),
    );
  }

  // ब्लॉक करने से पहले कन्फर्मेशन
  void _confirmBlock(String userId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("सावधान!"),
        content: Text("क्या आप $name को ब्लॉक करना चाहते हैं?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("नहीं")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance.collection('Users').doc(userId).delete(); // यहाँ आप 'blocked' स्टेटस भी सेट कर सकते हैं
              Navigator.pop(context);
            },
            child: Text("हाँ, ब्लॉक करें"),
          ),
        ],
      ),
    );
  }
}
