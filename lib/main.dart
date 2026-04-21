import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'vikas pasoriya',
    theme: ThemeData(primarySwatch: Colors.orange),
    home: Scaffold(
      appBar: AppBar(title: Text("vikas pasoriya")),
      drawer: Drawer(child: ListView(children: [
        DrawerHeader(child: Center(child: Text("गुरु जी की पाठशाला"))),
        ListTile(title: Text("पूर्णमासी कार्यक्रम")),
        ListTile(title: Text("डेवलपर: विवेक कौशिक (+917206966924)")),
      ])),
      body: Center(child: Text("App is Ready! Add Video Links from Admin")),
    ),
  ));
}
