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
      title: 'Vikas Pasoriya Official',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

// १. मुख्य चुनाव स्क्रीन (Admin vs User)
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
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
            const SizedBox(height: 50),
            _buildMainButton(context, "USER DASHBOARD", Colors.orange, const UserScreen()),
            const SizedBox(height: 20),
            _buildMainButton(context, "ADMIN CONTROL", Colors.red[900]!, const AdminLogin()),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context, String text, Color color, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(300, 65),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

// २. यूजर स्क्रीन (जहाँ पब्लिक को डेटा दिखेगा)
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String orgInfo = "Loading...";
  String progInfo = "Loading...";
  String ytUrl = "https://youtube.com";

  @override
  void initState() {
    super.initState();
    _fetchLiveSharedData();
  }

  _fetchLiveSharedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      orgInfo = prefs.getString('org_data') ?? "संस्था की जानकारी जल्द अपडेट होगी।";
      progInfo = prefs.getString('prog_data') ?? "नया प्रोग्राम जल्द आएगा।";
      ytUrl = prefs.getString('yt_data') ?? "https://youtube.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Public Updates")),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _displayCard("📢 संस्था की जानकारी", orgInfo),
          const SizedBox(height: 15),
          _displayCard("📅 प्रोग्राम अपडेट", progInfo),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill),
            label: const Text("YOUTUBE LIVE STREAM"),
            onPressed: () => launchUrl(Uri.parse(ytUrl)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)),
          ),
        ],
      ),
    );
  }

  Widget _displayCard(String title, String content) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const Divider(),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ३. एडमिन लॉगिन
class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Access")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(controller: _pass, decoration: const InputDecoration(labelText: "Enter Password", border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                String savedPass = prefs.getString('admin_pass') ?? "Vikas1998";
                if (_pass.text == savedPass) {
                  if (!mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("गलत पासवर्ड!")));
                }
              },
              child: const Text("LOGIN AS ADMIN"),
            )
          ],
        ),
      ),
    );
  }
}

// ४. एडमिन डैशबोर्ड (कंट्रोल सेंटर)
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Control Room"), backgroundColor: Colors.orange[900]),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(15),
        children: [
          _adminCard(context, Icons.business, "संस्था अपडेट", "org_data"),
          _adminCard(context, Icons.event, "प्रोग्राम अपडेट", "prog_data"),
          _adminCard(context, Icons.video_collection, "यूट्यूब लिंक", "yt_data"),
          _adminCard(context, Icons.lock_reset, "पासवर्ड बदलें", "pass_change"),
        ],
      ),
    );
  }

  Widget _adminCard(BuildContext context, IconData icon, String title, String key) {
    return Card(
      child: InkWell(
        onTap: () {
          if (key == "pass_change") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePassPage()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateDataPage(title: title, dataKey: key)));
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 45, color: Colors.orange[900]), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }
}

// ५. डेटा अपडेट करने का पेज
class UpdateDataPage extends StatefulWidget {
  final String title;
  final String dataKey;
  const UpdateDataPage({super.key, required this.title, required this.dataKey});

  @override
  State<UpdateDataPage> createState() => _UpdateDataPageState();
}

class _UpdateDataPageState extends State<UpdateDataPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _controller, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter New Info here...")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(widget.dataKey, _controller.text);
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text("SAVE AND UPDATE"),
            )
          ],
        ),
      ),
    );
  }
}

// ६. पासवर्ड बदलने का पेज
class ChangePassPage extends StatefulWidget {
  const ChangePassPage({super.key});
  @override
  State<ChangePassPage> createState() => _ChangePassPageState();
}

class _ChangePassPageState extends State<ChangePassPage> {
  final TextEditingController _newPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Admin Password")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(controller: _newPass, decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('admin_pass', _newPass.text);
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text("UPDATE PASSWORD"),
            )
          ],
        ),
      ),
    );
  }
}
