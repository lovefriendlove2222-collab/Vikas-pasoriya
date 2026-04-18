// ... बाकी imports वही रहेंगे

class VikasApp extends StatelessWidget {
  const VikasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('विकास पासोरिया ऑफिसियल'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      // डेटा यहाँ तै आवेगा
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menus').snapshots(),
        builder: (context, snapshot) {
          
          // १. अगर लोडिंग हो रही सै
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          // २. अगर कोई एरर आ गया (यही असली गड़बड़ पकड़ेगा)
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // ३. अगर डेटा मिल गया
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            String title = data['title'] ?? "हरि ॐ जी!";
            String desc = data['desc'] ?? "पाठशाला";

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fort_rounded, size: 80, color: Colors.deepOrange),
                  const SizedBox(height: 20),
                  Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          // ४. अगर डेटाबेस खाली सै
          return const Center(child: Text("डेटाबेस में कुछ कोनी मिल्या भाई!"));
        },
      ),
    );
  }
}
