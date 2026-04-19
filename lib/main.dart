import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(VikasOfficialApp());

class VikasOfficialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange, 
        scaffoldBackgroundColor: Color(0xFFFFF3E0)
      ),
      home: RoleSelectionScreen(),
    );
  }
}

// --- १. ऐप खुलने पर पहला पेज (यूजर या एडमिन चुनें) ---
class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("विकास पासोरिया ऑफिशियल"), backgroundColor: Colors.orange[900], centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🙏 हरि ॐ जी 🙏", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.orange[900])),
            SizedBox(height: 40),
            
            // यूजर बटन
            ElevatedButton.icon(
              icon: Icon(Icons.people, size: 28),
              label: Text("आम जनता (यूजर) यहाँ से जुड़ें", style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen())),
              style: ElevatedButton.styleFrom(minimumSize: Size(300, 60), backgroundColor: Colors.orange),
            ),
            
            SizedBox(height: 20),
            
            // एडमिन बटन
            ElevatedButton.icon(
              icon: Icon(Icons.admin_panel_settings, size: 28),
              label: Text("संस्था एडमिन लॉगिन", style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLogin())),
              style: ElevatedButton.styleFrom(minimumSize: Size(300, 60), backgroundColor: Colors.red[800], foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// --- २. आम जनता (यूजर) का पेज जहाँ जानकारी दिखेगी ---
class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String orgInfo = "संस्था की जानकारी लोड हो रही है...";
  String programInfo = "नए प्रोग्राम की जानकारी जल्द आएगी...";
  String youtubeLink = "https://youtube.com";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // एडमिन द्वारा सेव किया डाटा यहाँ से दिखेगा
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      orgInfo = prefs.getString('org_data') ?? "यहाँ संस्था की जानकारी दिखाई देगी।";
      programInfo = prefs.getString('program_data') ?? "अभी कोई नया प्रोग्राम अपडेट नहीं है।";
      youtubeLink = prefs.getString('yt_data') ?? "https://youtube.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("स्वागत है जी")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📢 संस्था की जानकारी:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                    SizedBox(height: 10),
                    Text(orgInfo, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📅 प्रोग्राम अपडेट:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                    SizedBox(height: 10),
                    Text(programInfo, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.play_circle_fill),
                label: Text("यूट्यूब पर लाइव स्टेज देखें"),
                onPressed: () => launchUrl(Uri.parse(youtubeLink)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 50)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- ३. एडमिन लॉगिन ---
class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("एडमिन सुरक्षा")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _passController, decoration: InputDecoration(labelText: "एडमिन पासवर्ड दर्ज करें", border: OutlineInputBorder()), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String savedPass = prefs.getString('admin_pass') ?? "Vikas1998";
                if (_passController.text == savedPass) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("गलत पासवर्ड!")));
                }
              },
              child: Text("लॉगिन करें"),
            )
          ],
        ),
      ),
    );
  }
}

// --- ४. एडमिन डैशबोर्ड (जहाँ से डाटा सेव होगा) ---
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("कंट्रोल रूम"), backgroundColor: Colors.orange[900]),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _adminOption(context, Icons.business, "संस्था जानकारी अपडेट करें", 'org_data'),
          _adminOption(context, Icons.event, "प्रोग्राम जानकारी अपडेट करें", 'program_data'),
          _adminOption(context, Icons.ondemand_video, "यूट्यूब लिंक बदलें", 'yt_data'),
          Divider(thickness: 2),
          ListTile(
            leading: Icon(Icons.key, color: Colors.red),
            title: Text("पासवर्ड बदलें"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen())),
          )
        ],
      ),
    );
  }

  Widget _adminOption(BuildContext context, IconData icon, String title, String dataKey) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange[900]),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.edit),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditDataScreen(title, dataKey))),
      ),
    );
  }
}

// --- ५. डाटा लिखने और सेव करने का पेज ---
class EditDataScreen extends StatefulWidget {
  final String title;
  final String dataKey;
  EditDataScreen(this.title, this.dataKey);

  @override
  _EditDataScreenState createState() => _EditDataScreenState();
}

class _EditDataScreenState extends State<EditDataScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  _loadExistingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _textController.text = prefs.getString(widget.dataKey) ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(hintText: "यहाँ नई जानकारी लिखें...", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString(widget.dataKey, _textController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("सफलतापूर्वक अपडेट हो गया!")));
                Navigator.pop(context);
              },
              child: Text("पब्लिक को दिखाएं (Save)"),
            )
          ],
        ),
      ),
    );
  }
}

// --- ६. पासवर्ड बदलने का पेज ---
class ChangePasswordScreen extends StatelessWidget {
  final TextEditingController _newPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("नया पासवर्ड सैट करें")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _newPass, decoration: InputDecoration(labelText: "नया पासवर्ड लिखें", border: OutlineInputBorder())),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('admin_pass', _newPass.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("पासवर्ड बदल गया!")));
                Navigator.pop(context);
              },
              child: Text("पासवर्ड सेव करें"),
            )
          ],
        ),
      ),
    );
  }
}
।
