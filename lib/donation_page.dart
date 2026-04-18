import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});
  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _village = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _amount = TextEditingController();
  bool _loading = false;

  _saveAndDonate() async {
    if (_name.text.isEmpty || _mobile.text.isEmpty || _amount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया पूरी जानकारी भरें!')));
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('donations').add({
        'name': _name.text,
        'mobile': _mobile.text,
        'village': _village.text,
        'city': _city.text,
        'state': _state.text,
        'amount': _amount.text,
        'time': DateTime.now(),
      });
      // यहाँ तू अपना पेमेंट लिंक या QR भी दिखा सके सै
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('डेटा सुरक्षित सेव हो गया!')));
      Navigator.pop(context);
    } catch (e) {
      print(e);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('विवरण भरें')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('सहयोग राशि हेतु अपनी जानकारी दें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'नाम (Name) *')),
            TextField(controller: _mobile, decoration: const InputDecoration(labelText: 'मोबाइल नम्बर *'), keyboardType: TextInputType.phone),
            TextField(controller: _village, decoration: const InputDecoration(labelText: 'गाँव (Village)')),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'शहर (City)')),
            TextField(controller: _state, decoration: const InputDecoration(labelText: 'राज्य (State)')),
            TextField(controller: _amount, decoration: const InputDecoration(labelText: 'राशि (Amount ₹) *'), keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _saveAndDonate, child: const Text('डेटा सेव करें और आगे बढ़ें')),
          ],
        ),
      ),
    );
  }
}
