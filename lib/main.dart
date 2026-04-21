import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization code here
  runApp(VikasPasoriyaApp());
}

class VikasPasoriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vikas pasoriya', // बिना डेश के नाम [Requirement 1]
      theme: ThemeData(primarySwatch: Colors.orange),
      home: MainDashboard(),
    );
  }
}

// 3, 4, 5. मैन डैशबोर्ड और वीडियो म्यूट फीचर
class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("vikas pasoriya")),
      drawer: buildLeftMenu(context), // 8, 9, 10. लेफ्ट मेनू
      endDrawer: buildRightAdminMenu(context), // 11, 14. राइट एडमिन मेनू
      body: Column(
        children: [
          // 4, 5. डोनर टिकर (डैशबोर्ड पर चलता हुआ नाम)
          Container(
            height: 30,
            color: Colors.yellow,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('donors').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                var donors = snapshot.data!.docs.map((d) => "${d['name']} (गांव: ${d['village']}) ने ₹${d['amount']} दान दिए").join(" | ");
                return Text(donors, style: TextStyle(fontWeight: FontWeight.bold));
              },
            ),
          ),
          
          // 3. वीडियो फीड (FB/YT लिंक म्यूट बटन के साथ)
          Expanded(
            child: ListView(
              children: [
                VideoPlayerWidget(videoUrl: "YOUR_YT_LINK_HERE"), // एडमिन पैनल से लिंक आएंगे
                // यहाँ हजारों वीडियो की लिस्ट एडमिन पैनल से सिंक होगी
              ],
            ),
          ),
          
          // 7. संस्था के डेली काम (Admin Post)
          buildDailyWorkSection(),
        ],
      ),
    );
  }

  // 14. राइट मेनू में डेवलपर संपर्क
  Widget buildRightAdminMenu(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(title: Text("एडमिन लॉगिन"), onTap: () {/* लॉगिन कोड */}),
          Divider(),
          ListTile(
            title: Text("एप डेवलोपर सम्पर्क"),
            subtitle: Text("विवेक कौशिक: +91 7206966924"), // [Requirement 14]
            leading: Icon(Icons.contact_phone),
          ),
        ],
      ),
    );
  }
}

// 12. डिजिटल रसीद फंक्शन
Future<void> generateReceipt(Map donorData) async {
  final pdf = pw.Document();
  pdf.addPage(pw.Page(
    build: (pw.Context context) => pw.Center(
      child: pw.Column(children: [
        pw.Text("संस्था का नाम: गुरु जी की पाठशाला"), // संस्था का नाम [Requirement 4]
        pw.Text("डोनर: ${donorData['name']}"),
        pw.Text("गांव: ${donorData['village']}"),
        pw.Text("मोबाईल: ${donorData['mobile']}"),
        pw.Text("राशि: ₹${donorData['amount']}"),
        pw.Text("समय: ${DateTime.now()}"),
      ]),
    ),
  ));
  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
