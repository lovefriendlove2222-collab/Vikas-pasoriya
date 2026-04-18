import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _passC = TextEditingController();
  
  _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedPass = prefs.getString('admin_pass') ?? "vikas@123";
    if (_passC.text == savedPass) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
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
            TextField(controller: _passC, decoration: const InputDecoration(labelText: 'पासवर्ड'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('लॉगिन'))
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
      appBar: AppBar(title: const Text('यूजर डेटा लिस्ट'), actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: () => _changePass(context))
      ]),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              var d = snap.data!.docs[i];
              return Card(
                child: ListTile(
                  title: Text(d['name']),
                  subtitle: Text("${d['mobile']} | ₹${d['amount']}\n${d['village']}, ${d['city']}"),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => d.reference.delete()),
                ),
              );
            },
          );
        },
      ),
    );
  }

  _changePass(context) {
    final newPass = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text('पासवर्ड बदलें'),
      content: TextField(controller: newPass),
      actions: [ElevatedButton(onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_pass', newPass.text);
        Navigator.pop(c);
      }, child: const Text('बदलें'))],
    ));
  }
}
