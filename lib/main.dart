// यूजर पेज का सही कोड
class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      body: Center(
        child: Text("यहाँ जनता को अपडेट दिखेंगे", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

// एडमिन लॉगिन पेज का सही कोड
class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Access")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "पासवर्ड दर्ज करें")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("लॉगिन करें"))
          ],
        ),
      ),
    );
  }
}
