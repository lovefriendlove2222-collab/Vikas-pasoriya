import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// १. सबसे जरूरी: यहाँ से एप शुरू होगा
void main() {
  runApp(const VikasOfficialApp());
}

class VikasOfficialApp extends StatelessWidget {
  const VikasOfficialApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vikas Pasoriya Official',
      theme: ThemeData(primarySwatch: Colors.orange, scaffoldBackgroundColor: const Color(0xFFFFF8F0)),
      home: const UserDashboard(),
    );
  }
}

// २. यूजर डैशबोर्ड (सीधा जनता को दिखेगा)
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String purnima = "अपडेट लोड हो रहा है...", regular = "अपडेट लोड हो रहा है...";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      purnima = prefs.getString("purnima_key") ?? "अगली पूर्णमासी का अपडेट जल्द आएगा।";
      regular = prefs.getString("regular_key") ?? "फिलहाल कोई रेगुलर प्रोग्राम नहीं है।";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियल"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin())).then((_) => _loadData()),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _infoCard("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange[800]!),
              _infoCard("📅 रेगुलर कार्यक्रम", regular, Colors.blueGrey[800]!),
              const SizedBox(height: 20),
              _actionBtn("📺 यूट्यूब लाइव", Colors.red, "https://youtube.com/@vikaspasoriya"),
              _actionBtn("📍 लोकेशन", Colors.green[700]!, "https://maps.google.com"),
              _actionBtn("📄 रशीद प्राप्त करें", Colors.brown, "", isAlert: true, msg: "रशीद के लिए एडमिन से मिलें।"),
              _actionBtn("💰 डोनेशन / दान", Colors.deepOrange, "", isAlert: true, msg: "दान के लिए धन्यवाद।"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String t, String c, Color col) {
    return Card(elevation: 4, margin: const EdgeInsets.only(bottom: 15),
      child: Padding(padding: const EdgeInsets.all(15), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col)),
        const Divider(),
        Text(c, style: const TextStyle(fontSize: 16)),
      ])),
    );
  }

  Widget _actionBtn(String t, Color c, String url, {bool isAlert = false, String msg = ""}) {
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)),
        onPressed: () => isAlert ? _showAlert(msg) : launchUrl(Uri.parse(url)),
        child: Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }

  _showAlert(String m) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(m)));
}

// ३. एडमिन लॉगिन (पासवर्ड: Vikas1998)
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final passController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("एडमिन लॉगिन")),
      body: Padding(padding: const EdgeInsets.all(25), child: Column(children: [
        TextField(controller: passController, decoration: const InputDecoration(labelText: "पासवर्ड", border: OutlineInputBorder()), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {
          if (passController.text == "Vikas1998") { 
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminPanel()));
          }
        }, child: const Text("लॉगिन"))
      ])),
    );
  }
}

// ४. एडमिन पैनल (सारे बटन सैट हैं)
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("एडमिन कंट्रोल"), backgroundColor: Colors.red[900]),
      body: GridView.count(
        crossAxisCount: 2, padding: const EdgeInsets.all(15), crossAxisSpacing: 10, mainAxisSpacing: 10,
        children: [
          _adminCard(context, "पूर्णमासी अपडेट", "purnima_key", Icons.event),
          _adminCard(context, "रेगुलर अपडेट", "regular_key", Icons.calendar_month),
          _adminCard(context, "रशीद/डोनेशन", "receipt", Icons.receipt_long),
          _adminCard(context, "संस्था जानकारी", "info", Icons.apartment),
        ],
      ),
    );
  }

  Widget _adminCard(BuildContext context, String t, String k, IconData i) {
    return Card(child: InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage(title: t, storageKey: k))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 40, color: Colors.orange[900]), Text(t)]),
    ));
  }
}

// ५. डेटा अपडेट करने का पेज
class EditPage extends StatefulWidget {
  final String title, storageKey;
  const EditPage({super.key, required this.title, required this.storageKey});
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _con = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: _con, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "नयी जानकारी लिखें...")),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () async {
          final p = await SharedPreferences.getInstance();
          await p.setString(widget.storageKey, _con.text);
          Navigator.pop(context);
        }, child: const Text("सेव करें"))
      ])),
    );
  }
}
