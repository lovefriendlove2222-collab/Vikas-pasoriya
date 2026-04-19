import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialisation Error: $e");
  }
  runApp(const VikasUltimateApp());
}

class VikasUltimateApp extends StatelessWidget {
  const VikasUltimateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vikas Pasoriya',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const AppDashboard(),
    );
  }
}

class AppDashboard extends StatefulWidget {
  const AppDashboard({super.key});
  @override
  State<AppDashboard> createState() => _AppDashboardState();
}

class _AppDashboardState extends State<AppDashboard> {
  // थारा डेटाबेस लिंक यहाँ फिक्स है
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/',
  ).ref();

  // डिफ़ॉल्ट डेटा (अगर डेटाबेस खाली हो तो भी ये दिखेगा)
  String liveInfo = "सूचना लोड हो रही है...";
  String upiAddress = "example@upi";
  String videoId = "4wrWluZisiw"; // डिफ़ॉल्ट वीडियो
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _startSyncing();
  }

  void _startSyncing() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          liveInfo = data["purnima"] ?? "आगामी कार्यक्रम की सूचना जल्द आएगी।";
          upiAddress = data["upi"] ?? "example@upi";
          final String rawVideo = data["videoId"] ?? "";
          final String? extractedId = YoutubePlayer.convertUrlToId(rawVideo);
          
          if (extractedId != null && extractedId != videoId) {
            videoId = extractedId;
            _ytController = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("विकास पासोरिया ऑफिशियिल", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => _adminLogin())],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // १. वीडियो सेक्शन
            if (_ytController != null)
              YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true)
            else
              Container(
                height: 220, 
                width: double.infinity,
                color: Colors.black, 
                child: const Center(child: Text("लाइव लोड हो रहा है...", style: TextStyle(color: Colors.white)))
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                _buildInfoCard("🌕 पूर्णमासी कार्यक्रम सूचना", liveInfo),
                const SizedBox(height: 20),
                _buildActionBtn("💰 डोनेशन (रशीद पाएँ)", Colors.green[800]!, Icons.qr_code, () => _showPayment()),
                const SizedBox(height: 10),
                _buildActionBtn("⭐ मंथली सदस्य बनें", Colors.blue[900]!, Icons.star_border, () => _showPayment()),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) => Card(
    elevation: 4,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const Divider(),
        Text(content, style: const TextStyle(fontSize: 16)),
      ]),
    ),
  );

  Widget _buildActionBtn(String txt, Color col, IconData ico, VoidCallback tap) => ElevatedButton.icon(
    icon: Icon(ico, color: Colors.white),
    label: Text(txt, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(
      backgroundColor: col, 
      minimumSize: const Size(double.infinity, 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
    ),
    onPressed: tap,
  );

  void _showPayment() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (c) => Container(
      padding: const EdgeInsets.all(25),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("QR कोड स्कैन करके दान करें", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        QrImageView(data: "upi://pay?pa=$upiAddress&pn=Vikas&cu=INR", size: 200),
        const SizedBox(height: 10),
        const Text("सहयोग के लिए आपका बहुत-बहुत धन्यवाद।"),
      ]),
    ));
  }

  void _adminLogin() {
    final TextEditingController _passCon = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("एडमिन लॉगिन"),
      content: TextField(controller: _passCon, decoration: const InputDecoration(labelText: "पासवर्ड"), obscureText: true),
      actions: [ElevatedButton(onPressed: () {
        if(_passCon.text == "Vikas1998") { 
          Navigator.pop(context); 
          Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminDashboard())); 
        }
      }, child: const Text("लॉगिन"))],
    ));
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final DatabaseReference _adminRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(), 
      databaseURL: 'https://vikas-pasoriya-default-rtdb.firebaseio.com/'
    ).ref();
    final TextEditingController _vCon = TextEditingController();
    final TextEditingController _pCon = TextEditingController();
    final TextEditingController _uCon = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("ऐप कंट्रोल पैनल")),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: _vCon, decoration: const InputDecoration(labelText: "नया यूट्यूब लिंक (Live)")),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () => _adminRef.update({"videoId": _vCon.text}), child: const Text("वीडियो लाइव करें")),
        const Divider(height: 40),
        TextField(controller: _pCon, decoration: const InputDecoration(labelText: "कार्यक्रम सूचना")),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () => _adminRef.update({"purnima": _pCon.text}), child: const Text("सूचना अपडेट करें")),
        const Divider(height: 40),
        TextField(controller: _uCon, decoration: const InputDecoration(labelText: "नया UPI ID सैट करें")),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () => _adminRef.update({"upi": _uCon.text}), child: const Text("UPI सेव करें")),
      ])),
    );
  }
}
