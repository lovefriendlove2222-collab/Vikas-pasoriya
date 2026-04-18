// ... (शुरुआत का कोड वही रहेगा)
body: StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance.collection('settilng').doc('app_config').snapshots(),
  builder: (context, snapshot) {
    
    // अगर डेटा मिल गया तो वो दिखाओ, नी तो सीधा ये डिफ़ॉल्ट दिखाओ (सफ़ेद स्क्रीन नी आएगी)
    String yt = (snapshot.hasData && snapshot.data!.exists) ? snapshot.data!['youtube'] : "https://youtube.com/@VikasPasoriya";
    String info = (snapshot.hasData && snapshot.data!.exists) ? snapshot.data!['about'] : "पंडित विकास पासोरिया पाठशाला";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fort_rounded, size: 100, color: Colors.deepOrange),
          const Text('हरि ॐ जी!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          const SizedBox(height: 20),
          Text(info, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () => launchUrl(Uri.parse(yt)),
            child: const Text("यूट्यूब चैनल", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  },
),
