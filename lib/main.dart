import 'package:flutter/material.dart';

// १. मशीन खातिर सबसे जरूरी: 'main' फंक्शन
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _buildButton(context, "USER DASHBOARD", Colors.orange, const UserScreen()),
            const SizedBox(height: 20),
            _buildButton(context, "ADMIN LOGIN", Colors.red[900]!, const AdminLogin()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(280, 60),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}

// २. यूजर स्क्रीन (जो खाली दिख रही थी, अब भरेगी)
class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Page")),
      body: const Center(
        child: Text("यहाँ जनता को अपडेट दिखेंगे", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

// ३. एडमिन लॉगिन स्क्रीन (खाली पेज का फिक्स)
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "पासवर्ड दर्ज करें",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, 
              child: const Text("लॉगिन करें"),
            )
          ],
        ),
      ),
    );
  }
}
