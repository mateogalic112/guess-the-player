
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palyer_guessing_app/auth/auth.dart';
import 'package:palyer_guessing_app/auth/login_page.dart';
import 'package:palyer_guessing_app/pages/root_page.dart';

class RegisterPage extends StatefulWidget {
  final BaseAuth auth;
  RegisterPage({@required this.auth});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _key = GlobalKey<FormState>();

  String _name;
  String _country;
  String _email;
  String _password;
  String userId;
  String id;
  String fileName;

  bool validateAndSave() {
    final form = _key.currentState;
    if(form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void createData() async {
    DocumentReference ref = await Firestore.instance.collection('Users').add({
      'name': _name,
      'country': _country,
      'email': _email,
      'userId': userId,
      'highscore': 0,
      'userAvatar': fileName
      });
      setState(() {
        id = ref.documentID; 
      });
  }

  void validateAndSubmit(BuildContext context) async {
    try {
      if(validateAndSave()) {
        userId = await widget.auth.createUserWithEmailAndPassword(
          _email, _password);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => RootPage(auth: Auth())
        ));
        print('$userId');
        uploadPic(context);
        createData();
      } 
    }catch (e) {
        print("Error: $e");
    }
  }

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future uploadPic(BuildContext context) async {
    fileName = basename(_image.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print(taskSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.greenAccent.withOpacity(0.6),
      body: Builder(
        builder: (context) =>
          SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 60
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Register', style: TextStyle(
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green,
                      child: ClipOval(
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: (_image != null) ? Image.file(_image, fit: BoxFit.cover) : Image.asset('assets/upit.png', fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: <Widget>[
                        Text(
                          'New avatar:', style: TextStyle(
                            fontSize: 16
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.camera,
                            size: 30,
                          ),
                          onPressed: () {
                            getImage();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Form(
                  key: _key,
                  child: Column(
                    children: <Widget>[
                      buildNewFields()[0],
                      buildNewFields()[1],
                      buildNewFields()[2],
                      buildNewFields()[3],
                    ],
                  ),
                ),
                SizedBox(height: 20),
                buildRegButton(context),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Already have an Account?', style: TextStyle(
                          fontSize: 16
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => LoginPage(auth: Auth())
                          ));
                        },
                        child: Text(
                          'Sign In!', style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildNewFields() {
    return [
      Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10
      ),
        child: TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Name',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          validator: (value) => value.isEmpty ? 
          'Name is empty!' : null,
          onSaved: (value) => _name = value,
        ),
      ),
      Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10
      ),
        child: TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Country',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          validator: (value) => value.isEmpty ? 
          'Country is empty!' : null,
          onSaved: (value) => _country = value[0].toUpperCase() + value.substring(1),
        ),
      ),
      Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10
      ),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          validator: (value) => value.isEmpty ? 
          'Email is empty!' : null,
          onSaved: (value) => _email = value,
        ),
      ),
      Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10
      ),
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          validator: (value) => value.length < 6 ? 
        'Password is too short! (6 chars min)' : null,
        onSaved: (value) => _password = value,
        ),
      )
    ];
  }

  Widget buildRegButton(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              Colors.greenAccent.withOpacity(0.3),
              Colors.greenAccent.withOpacity(0.8),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight
          ), 
        ),
        child: Center(
          child: GestureDetector(
              child: Text(
              'Register', style: TextStyle(
                fontSize: 20
              ),
            ),
            onTap: () {
              validateAndSubmit(context);
            }
          ),
        ),
      ),
    );
  }
}