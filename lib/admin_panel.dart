import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _passC = TextEditingController();
  
  _checkPass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedPass = prefs.getString('admin_pass') ?? "vikas@bhagwa";
    if (_passC.text == savedPass) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत पासवर्ड!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन लॉगिन')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _passC, decoration: const InputDecoration(labelText: 'पासवर्ड डालें'), obscureText: true),
            ElevatedButton(onPressed: _checkPass, child: const Text('प्रवेश करें')),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन कंट्रोल'), actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: () => _showChangePassDialog(context))
      ]),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var user = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(user['name']),
                  subtitle: Text("${user['village']} - ${user['mobile']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => FirebaseFirestore.instance.collection('users').doc(user.id).delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  _showChangePassDialog(BuildContext context) {
    final newPassC = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('नया एडमिन पासवर्ड'),
      content: TextField(controller: newPassC),
      actions: [
        ElevatedButton(onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_pass', newPassC.text);
          Navigator.pop(context);
        }, child: const Text('बदलें'))
      ],
    ));
  }
}
