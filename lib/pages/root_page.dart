import 'package:flutter/material.dart';
import 'package:palyer_guessing_app/auth/auth.dart';
import 'package:palyer_guessing_app/auth/login_page.dart';
import 'package:palyer_guessing_app/pages/home_page.dart';

class RootPage extends StatefulWidget {
  final BaseAuth auth;
  RootPage({this.auth});

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {

  AuthStatus _authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId){
      setState(() {
       _authStatus = userId == null ? AuthStatus.notSignedIn :
        AuthStatus.signedIn; 
      });
    });
  }

  void _signedIn() {
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
     _authStatus = AuthStatus.notSignedIn; 
    });
  }


  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        return LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        return HomePage(
          auth: widget.auth, 
          onSignedOut: _signedOut,
        );
    }
  }
}


