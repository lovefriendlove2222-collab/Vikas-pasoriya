import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: VikasApp(), debugShowCheckedModeBanner: false));
}

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vikas Pasoriya Official"), backgroundColor: Colors.orange),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("बादशाह DJ साउंड बाढड़ा", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // ऑनलाइन सिंक बटन (Firebase तै डेटा उठाएगा)
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(context: context, builder: (c) => Center(
                  child: QrImageView(data: "upi://pay?pa=7206966924vivek@axl&pn=Vikas", size: 250),
                ));
              },
              child: const Text("सहयोग राशि (UPI)"),
            ),
          ],
        ),
      ),
    );
  }
}
