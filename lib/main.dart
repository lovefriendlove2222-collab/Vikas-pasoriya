import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const VikasOfficialApp());
}

class VikasOfficialApp extends StatelessWidget {
  const VikasOfficialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vikas Pasoriya Official"),
        backgroundColor: Colors.orange[900],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🙏 HARI OM JI 🙏", 
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 50),
            _btn(context, "जनता के लिए (USER)", Colors.orange, const UserScreen()),
            const SizedBox(height: 20),
            _btn(context, "एडमिन कंट्रोल (ADMIN)", Colors.red[900]!, const AdminLogin()),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String txt, Color col, Widget pg) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(300, 60),
        backgroundColor: col,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => pg)),
      child: Text(txt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String info = "Loading...";
  String yt = "https://youtube.com";

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      info = p.getString('info') ?? "यहाँ विकास पासोरिया जी के प्रोग्राम की जानकारी दिखेगी।";
      yt = p.getString('yt') ?? "https://youtube.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Updates")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(info, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("YOUTUBE LIVE"),
              onPressed: () => launchUrl(Uri.parse(yt)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _c, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final p = await SharedPreferences.getInstance();
                if (_c.text == (p.getString('pass') ?? "Vikas1998")) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDash()));
                }
              },
              child: const Text("LOGIN"),
            )
          ],
        ),
      ),
    );
  }
}

class AdminDash extends StatelessWidget {
  const AdminDash({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("जानकारी बदलें"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditPage(k: 'info'))),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("यूट्यूब लिंक बदलें"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditPage(k: 'yt'))),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("पासवर्ड बदलें"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditPage(k: 'pass'))),
          ),
        ],
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  final String k;
  const EditPage({super.key, required this.k});
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _tc = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Data")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _tc, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final p = await SharedPreferences.getInstance();
                await p.setString(widget.k, _tc.text);
                Navigator.pop(context);
              },
              child: const Text("SAVE"),
            )
          ],
        ),
      ),
    );
  }
}
