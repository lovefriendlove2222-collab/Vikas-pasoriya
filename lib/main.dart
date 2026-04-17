import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart'; // नई लाइब्रेरी
import 'package:firebase_storage/firebase_storage.dart'; // नई लाइब्रेरी
import 'package:cloud_firestore/cloud_firestore.dart';
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
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameC = TextEditingController();
  final _villageC = TextEditingController();
  final _mobileC = TextEditingController();
  final _workC = TextEditingController();
  File? _image; // चुनी हुई फोटो यहाँ सेव होगी
  bool _isLoading = false;

  // गैलरी से फोटो लेने का फंक्शन
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50); // इमेज क्वालिटी कम कर दी ताकि जल्दी अपलोड हो
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // फोटो और डेटा Firebase में सेव करने का फंक्शन
  Future<void> _saveUser() async {
    if (_nameC.text.isEmpty || _mobileC.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया पूरी जानकारी और फोटो भरें!')));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      // 1. Firebase Storage में फोटो अपलोड करना
      String fileName = '${_mobileC.text}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child('user_photos').child(fileName);
      UploadTask uploadTask = storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String photoUrl = await snapshot.ref.getDownloadURL(); // अपलोड हुई फोटो का लिंक

      // 2. Firestore Database में डेटा सेव करना (फोटो लिंक के साथ)
      await FirebaseFirestore.instance.collection('users').add({
        'name': _nameC.text,
        'village': _villageC.text,
        'mobile': _mobileC.text,
        'work': _workC.text,
        'photoUrl': photoUrl, // फोटो का लिंक सेव कर लिया
        'status': 'active',
        'joinedAt': DateTime.now(),
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen())); // वापस स्वागत स्क्रीन पर
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया रजिस्ट्रेशन')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) // अपलोड हो रहा हो तो चकरी घुमाओ
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // फोटो अपलोड करने वाला हिस्सा
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120, width: 120,
                    decoration: BoxDecoration(color: Colors.deepOrange[100], borderRadius: BorderRadius.circular(60), border: Border.all(color: Colors.deepOrange, width: 2)),
                    child: _image == null
                        ? const Icon(Icons.add_a_photo, size: 50, color: Colors.deepOrange)
                        : ClipRRect(borderRadius: BorderRadius.circular(60), child: Image.file(_image!, fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('अपनी फोटो अपलोड करें', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'आपका नाम')),
                TextField(controller: _villageC, decoration: const InputDecoration(labelText: 'गाँव/शहर')),
                TextField(controller: _mobileC, decoration: const InputDecoration(labelText: 'मोबाईल नम्बर')),
                TextField(controller: _workC, decoration: const InputDecoration(labelText: 'क्या काम करते है')),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _saveUser, child: const Text('रजिस्टर होकर आईडी कार्ड पाए')),
              ],
            ),
          ),
    );
  }
}
