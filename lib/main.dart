import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const VikasOfficialApp());

class VikasOfficialApp extends StatelessWidget {
  const VikasOfficialApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const UserDashboard(),
    );
  }
}

// --- १. यूजर डैशबोर्ड (डेटा डिस्प्ले फिक्स) ---
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String purnima = "अपडेट आ रहा है...";
  String regular = "चेक कर रहे हैं...";

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  // डेटा लोड करने का पक्का तरीका
  _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      purnima = prefs.getString("purnima_data") ?? "अगली पूर्णमासी का अपडेट जल्द आएगा।";
      regular = prefs.getString("regular_data") ?? "फिलहाल कोई रेगुलर प्रोग्राम नहीं है।";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियल"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin())).then((_) => _loadStoredData()),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dataCard("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange),
            _dataCard("📅 रेगुलर कार्यक्रम", regular, Colors.blueGrey),
            const SizedBox(height: 20),
            _actionBtn("📺 यूट्यूब लाइव", Colors.red, "https://youtube.com/@vikaspasoriya"),
            _actionBtn("📍 लोकेशन", Colors.green[800]!, "https://maps.google.com"),
            // रशीद और डोनेशन अलग-अलग
            _actionBtn("📄 रशीद प्राप्त करें", Colors.brown, "", isAlert: true, msg: "अपनी रशीद के लिए संपर्क करें।"),
            _actionBtn("💰 डोनेशन / दान", Colors.deepOrange, "", isAlert: true, msg: "संस्था को दान देने के लिए धन्यवाद।"),
          ],
        ),
      ),
    );
  }

  Widget _dataCard(String title, String content, Color col) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col)),
            const Divider(),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color col, String url, {bool isAlert = false, String msg = ""}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: col,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          if (isAlert) {
            showDialog(context: context, builder: (c) => AlertDialog(content: Text(msg)));
          } else {
            launchUrl(Uri.parse(url));
          }
        },
        child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- २. एडमिन लॉगिन ---
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final passController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Access")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(controller: passController, decoration: const InputDecoration(labelText: "पासवर्ड", border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (passController.text == "Vikas1998") { // आपका मास्टर पासवर्ड
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminPanel()));
                }
              },
              child: const Text("लॉगिन"),
            )
          ],
        ),
      ),
    );
  }
}

// --- ३. एडमिन कंट्रोल पैनल ---
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("एडमिन कंट्रोल पैनल"), backgroundColor: Colors.red[900]),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(15),
        children: [
          _menuItem(context, "पूर्णमासी अपडेट", "purnima_data", Icons.brightness_high),
          _menuItem(context, "रेगुलर अपडेट", "regular_data", Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, String key, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditDataPage(title: title, storageKey: key))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 40, color: Colors.orange[900]), Text(title)],
        ),
      ),
    );
  }
}

// --- ४. डेटा अपडेट पेज (सेविंग फिक्स) ---
class EditDataPage extends StatefulWidget {
  final String title;
  final String storageKey;
  const EditDataPage({super.key, required this.title, required this.storageKey});
  @override
  State<EditDataPage> createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _controller, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "यहाँ नई जानकारी लिखें...")),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                bool success = await prefs.setString(widget.storageKey, _controller.text);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("डेटा सफलतापूर्वक सेव हो गया!")));
                  Navigator.pop(context);
                }
              },
              child: const Text("पक्का सेव करें"),
            )
          ],
        ),
      ),
    );
  }
}
