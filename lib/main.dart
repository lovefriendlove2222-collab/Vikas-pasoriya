import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

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

// --- १. यूजर डैशबोर्ड (सब कुछ एक साथ) ---
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<String> ytLinks = [];
  List<dynamic> donors = [];
  List<dynamic> monthlyDonors = [];
  String purnima = "", regular = "", upi = "", info = "";

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  _refreshAll() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      ytLinks = p.getStringList("yt_links") ?? ["https://youtube.com/@vikaspasoriya"];
      purnima = p.getString("purnima_val") ?? "अपडेट जल्द आएगा।";
      regular = p.getString("regular_val") ?? "कोई प्रोग्राम नहीं है।";
      info = p.getString("info_val") ?? "संस्था की जानकारी यहाँ दिखेगी।";
      upi = p.getString("upi_val") ?? "";
      donors = json.decode(p.getString("donors_list") ?? "[]");
      monthlyDonors = json.decode(p.getString("monthly_list") ?? "[]");
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
          // यूट्यूब हेडलाइन पट्टी
          if(ytLinks.isNotEmpty) Container(height: 45, color: Colors.red[900],
            child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: ytLinks.length,
              itemBuilder: (c, i) => InkWell(onTap: () => launchUrl(Uri.parse(ytLinks[i])), 
              child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), 
              child: Text("📺 LIVE: वीडियो ${i+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),
          ),
          
          // डोनर स्क्रॉलिंग पट्टी
          if(donors.isNotEmpty) Container(height: 30, color: Colors.orange[100],
            child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: donors.length,
              itemBuilder: (c, i) => Center(child: Text(" ✨ ${donors[i]['name']} (${donors[i]['village']}) | ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                _card("🌕 पूर्णमासी कार्यक्रम", purnima, Colors.orange),
                _card("📅 रेगुलर प्रोग्राम", regular, Colors.blueGrey),
                _card("ℹ️ संस्था के बारे में", info, Colors.green),
                const SizedBox(height: 10),
                _btn("💰 डोनेशन दें (रशीद पाएँ)", Colors.green[800]!, Icons.currency_rupee, () => _donationForm(false)),
                _btn("🗓️ मंथली डोनर सदस्य बनें", Colors.blue[900]!, Icons.calendar_month, () => _donationForm(true)),
                const Padding(padding: EdgeInsets.all(15), child: Text("🏆 हमारे मंथली डोनर्स", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ...monthlyDonors.map((m) => ListTile(leading: const Icon(Icons.stars, color: Colors.amber), title: Text(m['name']), subtitle: Text(m['village']))),
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

  // --- डोनेशन और रशीद लॉजिक ---
  _donationForm(bool isMonthly) {
    final n = TextEditingController(), v = TextEditingController(), m = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(isMonthly ? "मंथली डोनर मेंबर" : "डोनेशन रशीद"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: "आपका नाम")),
        TextField(controller: v, decoration: const InputDecoration(labelText: "गाँव")),
        TextField(controller: m, decoration: const InputDecoration(labelText: "मोबाइल नंबर")),
      ]),
      actions: [ElevatedButton(onPressed: () => _saveDonor(n.text, v.text, m.text, isMonthly), child: const Text("रशीद जनरेट करें"))],
    ));
  }

  _saveDonor(String name, String village, String phone, bool isM) async {
    final p = await SharedPreferences.getInstance();
    Map<String, String> d = {"name": name, "village": village, "phone": phone, "date": DateTime.now().toString().split(' ')[0]};
    if(isM) { monthlyDonors.add(d); await p.setString("monthly_list", json.encode(monthlyDonors)); }
    else { donors.add(d); await p.setString("donors_list", json.encode(donors)); }
    Navigator.pop(context);
    _showReceipt(d);
    _refreshAll();
  }

  _showReceipt(Map d) => showDialog(context: context, builder: (c) => AlertDialog(
    content: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("विक़ास पासोरिया संस्था", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        Text("डोनर: ${d['name']}"), Text("गाँव: ${d['village']}"), Text("तारीख: ${d['date']}"),
        const SizedBox(height: 10), const Text("🙏 आपका धन्यवाद 🙏"),
      ])),
  ));
}

// --- २. एडमिन लॉगिन ---
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    final pc = TextEditingController();
    return Scaffold(appBar: AppBar(title: const Text("Admin")), body: Padding(padding: const EdgeInsets.all(25), child: Column(children: [
      TextField(controller: pc, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () { if(pc.text == "Vikas1998") Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminDash())); }, child: const Text("Login"))
    ])));
  }
}

// --- ३. एडमिन डैशबोर्ड (हर एक ऑप्शन यहाँ से हैंडल होगा) ---
class AdminDash extends StatefulWidget {
  const AdminDash({super.key});
  @override
  State<AdminDash> createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  final _ytC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("फुल कंट्रोल पैनल"), backgroundColor: Colors.red[900]),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        const Text("🎥 यूट्यूब लिंक्स (Comma , लगाकर डालें)", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: _ytC, maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "link1, link2...")),
        ElevatedButton(onPressed: () async {
          final p = await SharedPreferences.getInstance();
          await p.setStringList("yt_links", _ytC.text.split(',').map((e) => e.trim()).toList());
        }, child: const Text("हेडलाइन अपडेट करें")),
        const Divider(height: 30),
        _at("🌕 पूर्णमासी अपडेट", "purnima_val"),
        _at("📅 रेगुलर प्रोग्राम", "regular_val"),
        _at("ℹ️ संस्था जानकारी", "info_val"),
        _at("💳 UPI ID (Donation)", "upi_val"),
        const Divider(),
        ListTile(title: const Text("📊 डोनर डेटा देखें"), leading: const Icon(Icons.people), onTap: () => _viewData("donors_list")),
        ListTile(title: const Text("💎 मंथली डोनर लिस्ट"), leading: const Icon(Icons.star), onTap: () => _viewData("monthly_list")),
      ]),
    );
  }

  Widget _at(String t, String k) => ListTile(title: Text(t), trailing: const Icon(Icons.edit), 
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => EditPage(t: t, k: k))));

  _viewData(String k) async {
    final p = await SharedPreferences.getInstance();
    List d = json.decode(p.getString(k) ?? "[]");
    showModalBottomSheet(context: context, builder: (c) => ListView.builder(itemCount: d.length, 
      itemBuilder: (c, i) => ListTile(title: Text(d[i]['name']), subtitle: Text("${d[i]['village']} - ${d[i]['phone']}"))));
  }
}

class EditPage extends StatelessWidget {
  final String t, k;
  EditPage({super.key, required this.t, required this.k});
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(t)), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: _c, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder())),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () async { 
        final p = await SharedPreferences.getInstance(); 
        await p.setString(k, _c.text); 
        Navigator.pop(context); 
      }, child: const Text("सेव करें"))
    ])));
  }
}
