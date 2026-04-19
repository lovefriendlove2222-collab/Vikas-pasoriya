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

// --- १. यूजर डैशबोर्ड (सब कुछ यहाँ दिखेगा) ---
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String purnima = "लोड हो रहा है...";
  String regular = "लोड हो रहा है...";

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  _refreshData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      purnima = p.getString("purnima") ?? "अगली पूर्णमासी का अपडेट जल्द आएगा।";
      regular = p.getString("regular") ?? "फिलहाल कोई रेगुलर प्रोग्राम नहीं है।";
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
          // एडमिन बटन जो तू कह रहा था गायब हो गया (अब यहाँ है)
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin())).then((_) => _refreshData()),
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            label: const Text("ADMIN", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        children: [
          _displayCard("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange[800]!),
          _displayCard("📅 रेगुलर कार्यक्रम", regular, Colors.blueGrey[800]!),
          const SizedBox(height: 20),
          _actionBtn("📺 यूट्यूब लाइव", Colors.red, "https://youtube.com/@vikaspasoriya"),
          _actionBtn("📍 लोकेशन", Colors.green[700]!, "http://google.com/maps"),
          _actionBtn("📄 रशीद", Colors.brown, "", isMsg: true, msg: "रशीद के लिए संपर्क करें।"),
          _actionBtn("💰 डोनेशन", Colors.deepOrange, "", isMsg: true, msg: "दान के लिए धन्यवाद।"),
        ],
      ),
    );
  }

  Widget _displayCard(String t, String c, Color col) {
    return Card(elevation: 4, margin: const EdgeInsets.only(bottom: 15),
      child: Padding(padding: const EdgeInsets.all(15), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col)),
        const Divider(),
        Text(c, style: const TextStyle(fontSize: 16)),
      ])),
    );
  }

  Widget _actionBtn(String t, Color c, String url, {bool isMsg = false, String msg = ""}) {
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
        onPressed: () => isMsg ? _showMsg(msg) : launchUrl(Uri.parse(url)),
        child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  _showMsg(String m) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(m)));
}

// --- २. एडमिन लॉगिन ---
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final pass = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("एडमिन लॉगिन")),
      body: Padding(padding: const EdgeInsets.all(25), child: Column(children: [
        TextField(controller: pass, decoration: const InputDecoration(labelText: "पासवर्ड", border: OutlineInputBorder()), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {
          if (pass.text == "Vikas1998") { // थारा मास्टर पासवर्ड
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminPanel()));
          }
        }, child: const Text("लॉगिन करें"))
      ])),
    );
  }
}

// --- ३. एडमिन कंट्रोल पैनल (कति थारी फोटो जैसा) ---
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("एडमिन कंट्रोल पैनल"), backgroundColor: Colors.red[900]),
      body: GridView.count(
        crossAxisCount: 2, padding: const EdgeInsets.all(15), crossAxisSpacing: 10, mainAxisSpacing: 10,
        children: [
          _menu(context, "रशीद/डोनेशन", "receipt", Icons.receipt_long),
          _menu(context, "प्रोग्राम अपडेट", "purnima", Icons.event_note),
          _menu(context, "संस्था जानकारी", "info", Icons.business),
          _menu(context, "UPI/QR सेटिंग", "upi", Icons.qr_code_2),
          _menu(context, "ID कार्ड मेकर", "id", Icons.badge),
          _menu(context, "फोटो/वीडियो", "media", Icons.add_a_photo),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, String t, String k, IconData i) {
    return Card(elevation: 5, child: InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage(title: t, storageKey: k))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(i, size: 45, color: Colors.orange[900]),
        const SizedBox(height: 10),
        Text(t, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ]),
    ));
  }
}

// --- ४. एडिटिंग पेज ---
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
        TextField(controller: _con, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "यहाँ लिखें...")),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          onPressed: () async {
            final p = await SharedPreferences.getInstance();
            await p.setString(widget.storageKey, _con.text);
            // रेगुलर प्रोग्राम के लिए अलग की (key)
            if(widget.storageKey == "purnima") await p.setString("regular", "चेक करें: " + _con.text);
            
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("सफलतापूर्वक सेव हो गया!")));
            Navigator.pop(context);
          }, 
          child: const Text("डाटा सेव करें")
        )
      ])),
    );
  }
}
