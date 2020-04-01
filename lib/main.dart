import 'package:flutter/material.dart';
import 'package:palyer_guessing_app/pages/root_page.dart';

import 'auth/auth.dart';


void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      home: RootPage(auth: Auth()),
    );
  }
}

