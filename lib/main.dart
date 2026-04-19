import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(const VikasUltimateApp());

class VikasUltimateApp extends StatelessWidget {
  const VikasUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, scaffoldBackgroundColor: const Color(0xFFFFFBF2)),
      home: const UserDashboard(),
    );
  }
}

// --- १. यूजर डैशबोर्ड (सब कंट्रोल यहाँ तै) ---
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<String> ytLinks = [];
  List<dynamic> donors = [];
  String purnima = "", regular = "", upiID = "", info = "";

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  _refreshAll() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      ytLinks = p.getStringList("yt_links") ?? [];
      purnima = p.getString("purnima_val") ?? "अपडेट जल्द आएगा।";
      regular = p.getString("regular_val") ?? "कोई प्रोग्राम नहीं है।";
      info = p.getString("info_val") ?? "संस्था की जानकारी यहाँ दिखेगी।";
      upiID = p.getString("upi_val") ?? "example@upi"; // एडमिन से बदलेगा
      donors = json.decode(p.getString("donors_list") ?? "[]");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया संस्था"),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(icon: const Icon(Icons.admin_panel_settings), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminLogin())).then((_) => _refreshAll()))
        ],
      ),
      body: Column(
        children: [
          // यूट्यूब हेडलाइन
          if(ytLinks.isNotEmpty) Container(height: 45, color: Colors.red[900],
            child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: ytLinks.length,
              itemBuilder: (c, i) => InkWell(onTap: () => launchUrl(Uri.parse(ytLinks[i])), 
              child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), 
              child: Text("📺 LIVE: वीडियो ${i+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                _card("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange),
                _card("📅 रेगुलर प्रोग्राम", regular, Colors.blueGrey),
                const SizedBox(height: 10),
                _btn("💰 दान करें (UPI/QR)", Colors.green[800]!, Icons.qr_code, () => _showPaymentSheet()),
                const Padding(padding: EdgeInsets.all(15), child: Text("🏆 डोनर्स की सूची", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ...donors.reversed.take(10).map((m) => ListTile(leading: const Icon(Icons.stars, color: Colors.amber), title: Text(m['name']), subtitle: Text(m['village']))),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String t, String c, Color col) => Card(margin: const EdgeInsets.all(10), elevation: 3, 
    child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: col)), const Divider(), Text(c)])));

  Widget _btn(String t, Color c, IconData i, VoidCallback tap) => Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
    child: ElevatedButton.icon(icon: Icon(i), label: Text(t), style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)), onPressed: tap));

  // --- २. पेमेंट और रशीद सिस्टम ---
  _showPaymentSheet() {
    showModalBottomSheet(context: context, builder: (c) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("स्कैन करें या UPI से पे करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        QrImageView(data: "upi://pay?pa=$upiID&pn=VikasPasoriya&cu=INR", size: 180),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () async {
            await launchUrl(Uri.parse("upi://pay?pa=$upiID&pn=VikasPasoriya&cu=INR"));
            Navigator.pop(context);
            _askDetails(); // पेमेंट के बाद डिटेल पूछणा
          },
          child: const Text("पेमेंट कर दिया (डिटेल भरें)")
        )
      ]),
    ));
  }

  _askDetails() {
    final n = TextEditingController(), v = TextEditingController(), m = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: const Text("रशीद के लिए जानकारी दें"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: "नाम")),
        TextField(controller: v, decoration: const InputDecoration(labelText: "गाँव")),
        TextField(controller: m, decoration: const InputDecoration(labelText: "मोबाइल")),
      ]),
      actions: [ElevatedButton(onPressed: () => _saveAndReceipt(n.text, v.text, m.text), child: const Text("रशीद प्राप्त करें"))],
    ));
  }

  _saveAndReceipt(String name, String village, String phone) async {
    final p = await SharedPreferences.getInstance();
    Map<String, String> d = {"name": name, "village": village, "phone": phone, "date": DateTime.now().toString().split(' ')[0]};
    donors.add(d);
    await p.setString("donors_list", json.encode(donors));
    Navigator.pop(context);
    _showDigitalReceipt(d);
    _refreshAll();
  }

  _showDigitalReceipt(Map d) => showDialog(context: context, builder: (c) => AlertDialog(
    content: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("विक़ास पासोरिया संस्था", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        Text("डोनर: ${d['name']}"), Text("गाँव: ${d['village']}"), Text("तारीख: ${d['date']}"),
        const SizedBox(height: 15), const Text("🙏 धन्यवाद् - रशीद सेव करलें 🙏", style: TextStyle(fontSize: 12)),
      ])),
  ));
}

// --- ३. एडमिन पैनल (डेटा अपडेट फिक्स) ---
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final pc = TextEditingController();
    return Scaffold(appBar: AppBar(title: const Text("Admin")), body: Padding(padding: const EdgeInsets.all(25), child: Column(children: [
      TextField(controller: pc, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () { if(pc.text == "Vikas1998") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminDash())); }, child: const Text("लॉगिन"))
    ])));
  }
}

class AdminDash extends StatefulWidget {
  const AdminDash({super.key});
  @override
  State<AdminDash> createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  final _ytC = TextEditingController();
  final _upiC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("एडमिन कंट्रोल"), backgroundColor: Colors.red[900]),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        _field("UPI ID (Paytm/GPay)", _upiC, "upi_val"),
        _field("यूट्यूब लिंक (कॉमा , लगाकै)", _ytC, "yt_links", isList: true),
        const Divider(),
        _tile("🌕 पूर्णमासी अपडेट", "purnima_val"),
        _tile("📅 रेगुलर प्रोग्राम", "regular_val"),
        _tile("ℹ️ संस्था जानकारी", "info_val"),
      ]),
    );
  }

  Widget _field(String l, TextEditingController c, String k, {bool isList = false}) => Column(children: [
    TextField(controller: c, decoration: InputDecoration(labelText: l)),
    ElevatedButton(onPressed: () async {
      final p = await SharedPreferences.getInstance();
      if(isList) await p.setStringList(k, c.text.split(',').map((e) => e.trim()).toList());
      else await p.setString(k, c.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("सफलतापूर्वक अपडेट!")));
    }, child: const Text("अपडेट"))
  ]);

  Widget _tile(String t, String k) => ListTile(title: Text(t), trailing: const Icon(Icons.edit), 
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => EditPage(t: t, k: k))));
}

class EditPage extends StatelessWidget {
  final String t, k;
  EditPage({super.key, required this.t, required this.k});
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(t)), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: _c, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder())),
      ElevatedButton(onPressed: () async { 
        final p = await SharedPreferences.getInstance(); 
        await p.setString(k, _c.text); 
        Navigator.pop(context); 
      }, child: const Text("सेव करें"))
    ])));
  }
}
