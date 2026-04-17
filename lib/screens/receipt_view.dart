import 'package:flutter/material.dart';

class DonationReceipt extends StatelessWidget {
  final String donorName;
  final String amount;
  final String date;
  final String scheme;

  DonationReceipt({required this.donorName, required this.amount, required this.date, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("आपकी दान रसीद"), backgroundColor: Colors.orange[900]),
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange[900]!, width: 3),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("विकास पासोरिया ऑफिसियल", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange[900])),
              Text("🚩 हरि ॐ जी 🚩", style: TextStyle(fontSize: 16)),
              Divider(thickness: 2),
              SizedBox(height: 10),
              receiptRow("दानदाता:", donorName),
              receiptRow("राशि:", "₹$amount"),
              receiptRow("योजना:", scheme),
              receiptRow("दिनांक:", date),
              SizedBox(height: 30),
              Text("धन्यवाद! आपका सहयोग हमारे लिए अमूल्य है।", textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(height: 20),
              // यहाँ आप अपना डिजिटल साइन या मुहर लगा सकते हैं
              Icon(Icons.verified, color: Colors.green, size: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
