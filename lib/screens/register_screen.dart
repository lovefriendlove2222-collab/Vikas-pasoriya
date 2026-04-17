import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // इनपुट लेने के लिए कंट्रोलर्स
  TextEditingController nameController = TextEditingController();
  TextEditingController villageController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController workController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("नया सदस्य पंजीकरण", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[900], // गहरा भगवा
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.person_add, size: 80, color: Colors.orange[800]),
              SizedBox(height: 20),
              
              // नाम इनपुट
              buildTextField(nameController, "पूरा नाम", Icons.person),
              // गाँव इनपुट
              buildTextField(villageController, "गाँव का नाम", Icons.home),
              // शहर इनपुट
              buildTextField(cityController, "शहर", Icons.location_city),
              // मोबाइल इनपुट
              buildTextField(phoneController, "मोबाइल नम्बर", Icons.phone, inputType: TextInputType.phone),
              // काम (Profession) इनपुट
              buildTextField(workController, "आप क्या काम करते हैं?", Icons.work),
              // पासवर्ड इनपुट
              buildTextField(passwordController, "पॉसवर्ड सेट करें", Icons.lock, isPassword: true),
              
              SizedBox(height: 30),
              
              // रजिस्टर बटन
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900]),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // यहाँ डेटाबेस में सेव करने का कोड आएगा
                      print("रजिस्टर हो रहा है...");
                    }
                  },
                  child: Text("पंजीकरण करें और यूजर आईडी लें", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // कॉमन टेक्स्ट फील्ड डिजाइन
  Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange[900]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange[900]!, width: 2)),
        ),
        validator: (value) => value!.isEmpty ? "यह जानकारी ज़रूरी है" : null,
      ),
    );
  }
}
