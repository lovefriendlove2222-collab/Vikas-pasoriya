import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VikasApp());
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        textTheme: GoogleFonts.hindTextTheme(),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// 1. स्वागत स्क्रीन
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
            const SizedBox(height: 20),
            const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const Text('विकास पासोरिया ऑफिसियल एप', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
              child: const Text('रजिस्टर/लॉगिन करें', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPage())),
              child: const Text('एडमिन पैनल', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. फोटो के साथ रजिस्ट्रेशन
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  File? _img;
  bool _loading = false;

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (file != null) setState(() => _img = File(file.path));
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _img == null) return;
    setState(() => _loading = true);
    try {
      String path = 'users/${_mobile.text}.jpg';
      var ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(_img!);
      String url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').add({
        'name': _name.text,
        'mobile': _mobile.text,
        'photo': url,
        'time': DateTime.now(),
      });
      Navigator.pop(context);
    } catch (e) { print(e); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया रजिस्ट्रेशन')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pick,
              child: CircleAvatar(radius: 60, backgroundImage: _img != null ? FileImage(_img!) : null, child: _img == null ? const Icon(Icons.add_a_photo, size: 40) : null),
            ),
            const SizedBox(height: 20),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'आपका नाम')),
            TextField(controller: _mobile, decoration: const InputDecoration(labelText: 'मोबाईल नम्बर')),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _save, child: const Text('रजिस्टर करें')),
          ],
        ),
      ),
    );
  }
}

// 3. एडमिन पैनल (यूजर लिस्ट)
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन कंट्रोल'), backgroundColor: Colors.deepOrange),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              var user = snap.data!.docs[i];
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(user['photo'])),
                title: Text(user['name']),
                subtitle: Text(user['mobile']),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => user.reference.delete()),
              );
            },
          );
        },
      ),
    );
  }
}
