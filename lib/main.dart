import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(const VikasSuperApp());

class VikasSuperApp extends StatelessWidget {
  const VikasSuperApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, scaffoldBackgroundColor: const Color(0xFFFFF3E0)),
      home: const UserDashboard(),
    );
  }
}

// --- १. यूजर डैशबोर्ड (सीधा यही खुलेगा) ---
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String purnima = "लोड हो रहा है...", regular = "लोड हो रहा है...", yt = "https://youtube.com/@vikaspasoriya", loc = "https://maps.google.com";

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  _refreshData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      purnima = p.getString("पूर्णमासी कार्यक्रम") ?? "अगली पूर्णमासी का अपडेट जल्द आएगा।";
      regular = p.getString("रेगुलर कार्यक्रम") ?? "फिलहाल कोई रेगुलर प्रोग्राम नहीं है।";
      yt = p.getString("यूट्यूब चैनल") ?? "https://youtube.com/@vikaspasoriya";
      loc = p.getString("लोकेशन") ?? "https://maps.google.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियल"),
        backgroundColor: Colors.orange[900],
        actions: [
          // एडमिन बटन कोने में छुपा दिया सै
          IconButton(icon: const Icon(Icons.security, color: Colors.white), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin())))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _infoCard("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange[800]!),
          _infoCard("📅 रेगुलर कार्यक्रम", regular, Colors.blueGrey[800]!),
          const SizedBox(height: 20),
          _actionBtn("📺 यूट्यूब लाइव", Colors.red, yt, Icons.play_circle),
          _actionBtn("📍 लोकेशन", Colors.green[700]!, loc, Icons.location_on),
          _actionBtn("📝 रशीद / डोनेशन", Colors.orange[900]!, "", Icons.receipt, isReceipt: true),
        ],
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

  Widget _actionBtn(String t, Color c, String url, IconData i, {bool isReceipt = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(icon: Icon(i), label: Text(t),
        onPressed: () => isReceipt ? _showReceipt() : launchUrl(Uri.parse(url)),
        style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)),
      ),
    );
  }

  _showReceipt() {
    showModalBottomSheet(context: context, builder: (context) => Container(padding: const EdgeInsets.all(20), 
    child: const Text("रशीद और डोनेशन के लिए एडमिन से संपर्क करें।", style: TextStyle(fontSize: 16))));
  }
}

// --- २. एडमिन लॉगिन ---
class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _pass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Access")),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: _pass, decoration: const InputDecoration(labelText: "पासवर्ड", border: OutlineInputBorder()), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () async {
          final p = await SharedPreferences.getInstance();
          if (_pass.text == (p.getString('admin_pass') ?? "Vikas1998")) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminPanel()));
          }
        }, child: const Text("लॉगिन"))
      ])),
    );
  }
}

// --- ३. एडमिन पैनल (सारे अपडेट यहीं से होंगे) ---
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("कंट्रोल पैनल"), backgroundColor: Colors.red[900]),
      body: GridView.count(
        crossAxisCount: 2, padding: const EdgeInsets.all(15), crossAxisSpacing: 10, mainAxisSpacing: 10,
        children: [
          _adminCard(context, "पूर्णमासी कार्यक्रम", Icons.brightness_3),
          _adminCard(context, "रेगुलर कार्यक्रम", Icons.event),
          _adminCard(context, "यूट्यूब चैनल", Icons.video_collection),
          _adminCard(context, "लोकेशन", Icons.pin_drop),
          _adminCard(context, "पासवर्ड बदलें", Icons.vibration),
        ],
      ),
    );
  }

  Widget _adminCard(BuildContext context, String t, IconData i) {
    return Card(child: InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditPage(title: t))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 40, color: Colors.red[900]), Text(t)]),
    ));
  }
}

// --- ४. एडिटिंग पेज ---
class EditPage extends StatefulWidget {
  final String title;
  const EditPage({super.key, required this.title});
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _tc = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: _tc, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "नयी जानकारी यहाँ लिखें...")),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () async {
          final p = await SharedPreferences.getInstance();
          if (widget.title == "पासवर्ड बदलें") {
            await p.setString('admin_pass', _tc.text);
          } else {
            await p.setString(widget.title, _tc.text);
          }
          Navigator.pop(context);
        }, child: const Text("सेव करें"))
      ])),
    );
  }
}
