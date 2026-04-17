import 'package:flutter/material.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _passController = TextEditingController();
  // भाई तेरा पासवर्ड यहाँ सै, इसे बदल सकै सै तू
  final String superAdminPass = "vikas@bhagwa"; 

  void _checkLogin() {
    if (_passController.text == superAdminPass) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत पासवर्ड!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सुपर एडमिन लॉगिन'), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.security, size: 80, color: Colors.black),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: 'एडमिन पासवर्ड'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _checkLogin, child: const Text('पैनल खोलें')),
          ],
        ),
      ),
    );
  }
}

// एडमिन कंट्रोल सेंटर
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन कंट्रोल सेंटर'), backgroundColor: Colors.deepOrange),
      body: GridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: 2,
        children: [
          _adminCard(context, 'यूजर रिमूव/ब्लॉक', Icons.block, Colors.red),
          _adminCard(context, 'डोनेशन स्कीम', Icons.add_chart, Colors.green),
          _adminCard(context, 'रसीद ले-आउट', Icons.edit_note, Colors.blue),
          _adminCard(context, 'UPI/QR अपडेट', Icons.qr_code_scanner, Colors.orange),
          _adminCard(context, 'आईडी कार्ड जारी करें', Icons.badge, Colors.purple),
          _adminCard(context, 'प्रोग्राम अपडेट', Icons.notification_add, Colors.brown),
        ],
      ),
    );
  }

  Widget _adminCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () { /* यहाँ हर फीचर की अलग सेटिंग खुलेगी */ },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
