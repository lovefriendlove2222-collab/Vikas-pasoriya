import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // अगर चाबी (json file) नहीं मिली, तो ऐप क्रैश नहीं होगा
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Error: $e");
  }
  runApp(const VikasApp());
}

// ... बाकी का एडमिन और रजिस्ट्रेशन कोड जो कल दिया था ...
