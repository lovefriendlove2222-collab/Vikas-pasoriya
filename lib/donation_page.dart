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

  _sendData() async {
    if (_name.text.isEmpty || _mobile.text.isEmpty) return;
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
      // यहाँ पेमेंट गेटवे का लिंक भी डाल सकते हो
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('डेटा सुरक्षित सेव हो गया!')));
      Navigator.pop(context);
    } catch (e) { print(e); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('विवरण भरें')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'नाम')),
            TextField(controller: _mobile, decoration: const InputDecoration(labelText: 'मोबाइल')),
            TextField(controller: _village, decoration: const InputDecoration(labelText: 'गाँव')),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'शहर')),
            TextField(controller: _state, decoration: const InputDecoration(labelText: 'राज्य')),
            TextField(controller: _amount, decoration: const InputDecoration(labelText: 'राशि (₹)'), keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _sendData, child: const Text('सेव करें और आगे बढ़ें')),
          ],
        ),
      ),
    );
  }
}
