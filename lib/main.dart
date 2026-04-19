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
        scaffoldBackgroundColor: const Color(0xFFFFF3E0)
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
      appBar: AppBar(title: const Text("Vikas Pasoriya Official"), backgroundColor: Colors.orange[900]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("HARI OM JI", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserScreen())),
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 60), backgroundColor: Colors.orange),
              child: const Text("USER LOGIN", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin())),
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 60), backgroundColor: Colors.red[800], foregroundColor: Colors.white),
              child: const Text("ADMIN LOGIN", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String orgInfo = "Loading...";
  String programInfo = "Loading...";
  String youtubeLink = "https://youtube.com";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      orgInfo = prefs.getString('org_data') ?? "Vikas Pasoriya Foundation Info";
      programInfo = prefs.getString('program_data') ?? "No Updates Yet";
      youtubeLink = prefs.getString('yt_data') ?? "https://youtube.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Public Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(child: ListTile(title: const Text("Organization Info"), subtitle: Text(orgInfo))),
            Card(child: ListTile(title: const Text("Program Update"), subtitle: Text(programInfo))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(youtubeLink)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("Watch on YouTube"),
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
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _pass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Access")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _pass, decoration: const InputDecoration(labelText: "Enter Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                String savedPass = prefs.getString('admin_pass') ?? "Vikas1998";
                if (_pass.text == savedPass) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                }
              },
              child: const Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Control")),
      body: ListView(
        children: [
          ListTile(title: const Text("Update Org Info"), leading: const Icon(Icons.edit), onTap: () {}),
          ListTile(title: const Text("Update YouTube Link"), leading: const Icon(Icons.link), onTap: () {}),
          ListTile(title: const Text("Change Password"), leading: const Icon(Icons.key), onTap: () {}),
        ],
      ),
    );
  }
}
