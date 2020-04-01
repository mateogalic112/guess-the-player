import 'package:flutter/material.dart';
import 'package:palyer_guessing_app/auth/auth.dart';
import 'package:palyer_guessing_app/auth/register.dart';

class LoginPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  LoginPage({@required this.auth, this.onSignedIn});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _email;
  String _password;
  String userId;
  bool _obscure = true;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    try {
      if (validateAndSave()) {
        userId =
            await widget.auth.signInWithEmailAndPassword(_email, _password);
        print("User: $userId");
        widget.onSignedIn();
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar();
    }
  }

  _showSnackBar() {
    final snackBar = SnackBar(
      content: Text(
        "Wrong username or password!", style: TextStyle(
          fontSize: 16
        ),
        ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.greenAccent.withOpacity(0.5),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Text(
              'Player Guessing Game',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  buildTextField('Email'),
                  buildTextField('Password'),
                ],
              ),
            ),
      
            SizedBox(height: 40),
            buildButton(context),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    child: Text(
                      'Sign Up!',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RegisterPage(auth: Auth())));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: title,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          prefixIcon:
              title == "Email" ? Icon(Icons.email) : Icon(Icons.lock_outline),
          suffixIcon: title == "Password"
              ? IconButton(
                  icon: _obscure
                      ? Icon(Icons.visibility_off)
                      : Icon(Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                )
              : null,
        ),
        obscureText: title == 'Password' ? _obscure : false,
        validator: title == 'Email'
            ? (value) => value.isEmpty ? 'Email is empty!' : null
            : (value) => value.length < 6
                ? 'Password is too short! (6 chars min)'
                : null,
        onSaved: title == 'Email'
            ? (value) => _email = value
            : (value) => _password = value,
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return GestureDetector(
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(colors: [
              Colors.green.withOpacity(0.2),
              Colors.greenAccent.withOpacity(0.4)
            ], begin: Alignment.centerRight, end: Alignment.bottomLeft),
          ),
          child: Center(
            child: Text(
              'Sign In',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        onTap: validateAndSubmit,
    );
  }
}
