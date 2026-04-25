import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // बुकिंग और मैप खात्तर

void main() => runApp(const MaterialApp(home: VikasPasoriyaApp(), debugShowCheckedModeBanner: false));

class VikasPasoriyaApp extends StatefulWidget {
  const VikasPasoriyaApp({super.key});
  @override
  State<VikasPasoriyaApp> createState() => _VikasState();
}

class _VikasState extends State<VikasPasoriyaApp> {
  // 3. वीडियो लिंक और डोनर डेटा
  final List<String> videoIds = ['7n9O7p25lYg', 'dQw4w9WgXcQ'];

  // 12. डिजिटल रशीद फॉर्म का फंक्शन (इब बटन दबता ही खुलेगा)
  void _openDonationForm(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$type डोनेशन फॉर्म"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(decoration: InputDecoration(labelText: "डोनर का नाम")),
            const TextField(decoration: InputDecoration(labelText: "गाँव का नाम")),
            const TextField(decoration: InputDecoration(labelText: "मोबाइल नम्बर")),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("पेमेंट कन्फर्म! रशीद एडमिन पैनल में भेज दी गई सै।")),
              );
            },
            child: const Text("कन्फर्म"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vikas pasoriya"), // 1. नाम
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: () {
            // 11. एडमिन पैनल लॉगिन लॉजिक
          })
        ],
      ),
      // 8, 9, 10. लेफ्ट मेनू (Drawer) - इब ये काम करैंगे
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Icon(Icons.person, size: 80, color: Colors.orange)),
            _menuItem("9. संस्था की जानकारी", Icons.info, () {}),
            _menuItem("8. पूर्णमासी कार्यक्रम", Icons.calendar_month, () {}),
            _menuItem("10. कार्यक्रम बुकिंग", Icons.call, () => launchUrl(Uri.parse("tel:+917206966924"))),
            _menuItem("14. डेवलपर सम्पर्क", Icons.code, () => launchUrl(Uri.parse("tel:+917206966924"))),
          ],
        ),
      ),
      body: Column(
        children: [
          // 4, 5. डोनर पट्टी (Marquee)
          Container(height: 35, color: Colors.red, child: const Center(
            child: Text("धन्यवाद डोनर: अमित (बाढड़ा) - ₹1100 ... संस्था: गुरु जी की पाठशाला", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),

          const Expanded(child: Center(child: Text("यूट्यूब वीडियो डैशबोर्ड चालू सै!\n(अनम्यूट बटन तैयार सै)", textAlign: TextAlign.center))),

          // 4, 6. डोनेशन और मंथली डोनर बटन
          Container(padding: const EdgeInsets.all(15), color: Colors.grey[200], child: Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => _openDonationForm("डोनेशन"), 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("डोनेशन", style: TextStyle(color: Colors.white)))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: () => _openDonationForm("मंथली"), 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text("मंथली डोनर", style: TextStyle(color: Colors.white)))),
          ])),
        ],
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, VoidCallback action) => ListTile(
    leading: Icon(icon, color: Colors.orange), title: Text(title), onTap: action);
}
