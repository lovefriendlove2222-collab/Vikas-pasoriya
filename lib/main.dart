import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      theme: ThemeData(primarySwatch: Colors.deepOrange, textTheme: GoogleFonts.hindTextTheme()),
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
            const Text('स्वागत है विकास पासोरिया ऑफिसियल एप में', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
              child: const Text('लॉगिन / रजिस्टर करें', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage())),
              child: const Text('एडमिन लॉगिन', style: TextStyle(color: Colors.grey)),
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
  final _nameC = TextEditingController();
  final _mobileC = TextEditingController();
  File? _image;
  bool _isLoading = false;

  _pickImg() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (file != null) setState(() => _image = File(file.path));
  }

  _submit() async {
    if (_nameC.text.isEmpty || _image == null) return;
    setState(() => _isLoading = true);
    try {
      String fileName = '${_mobileC.text}.jpg';
      var ref = FirebaseStorage.instance.ref().child('users').child(fileName);
      await ref.putFile(_image!);
      String url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').add({
        'name': _nameC.text,
        'mobile': _mobileC.text,
        'photo': url,
        'date': DateTime.now(),
      });
      Navigator.pop(context);
    } catch (e) { print(e); }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया रजिस्ट्रेशन')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImg,
              child: CircleAvatar(radius: 60, backgroundImage: _image != null ? FileImage(_image!) : null, child: _image == null ? const Icon(Icons.add_a_photo) : null),
            ),
            TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'नाम')),
            TextField(controller: _mobileC, decoration: const InputDecoration(labelText: 'मोबाइल')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text('डाटा सेव करें')),
          ],
        ),
      ),
    );
  }
}

// 3. एडमिन पैनल (यूजर लिस्ट)
class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('एडमिन कंट्रोल')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return const CircularProgressIndicator();
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
