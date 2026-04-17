import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  // डिटेल्स जो आपने मांगी थी
  String name = '', village = '', city = '', mobile = '', work = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('नया रजिस्ट्रेशन')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'आपका नाम'), onChanged: (val) => name = val),
              TextFormField(decoration: const InputDecoration(labelText: 'गाँव'), onChanged: (val) => village = val),
              TextFormField(decoration: const InputDecoration(labelText: 'शहर'), onChanged: (val) => city = val),
              TextFormField(decoration: const InputDecoration(labelText: 'मोबाईल नम्बर'), keyboardType: TextInputType.phone, onChanged: (val) => mobile = val),
              TextFormField(decoration: const InputDecoration(labelText: 'क्या काम करते है'), onChanged: (val) => work = val),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // यहाँ से डेटा Firebase में जाएगा
                },
                child: const Text('रजिस्टर होकर आईडी कार्ड पाए'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
