import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _pass = TextEditingController();
  _login() {
    if (_pass.text == "vikas@bhagwa") { // तेरा पासवर्ड
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
        child: Column(children: [
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'पासवर्ड दर्ज करें'), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _login, child: const Text('लॉगिन करें'))
        ]),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('डोनेशन लिस्ट')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('time', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              var d = snap.data!.docs[i];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("${d['name']} - ₹${d['amount']}"),
                  subtitle: Text("${d['mobile']}\n${d['village']}, ${d['city']}, ${d['state']}"),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => d.reference.delete()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
