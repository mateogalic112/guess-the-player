import 'package:flutter/material.dart';
import 'package:palyer_guessing_app/auth/auth.dart';
import 'game_page.dart';
import '../services/name.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  HomePage({@required this.auth, this.onSignedOut});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  var userName;
  String country;

  getName() {
    widget.auth.currentUser().then((userId) {
      FirebaseQuery().getNameQuery(userId).then((value) {
        if (value.documents.isNotEmpty) {
          userName = value.documents[0].data;
          country = userName['country'];
        } else {
          print('Error');
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {});

    getName();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween(begin: 0.3, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      print('Signed Out');
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: userName == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: <Widget>[
                Container(
                  height: height,
                  width: width,
                  color: Colors.greenAccent.withOpacity(0.5),
                ),
                Positioned(
                  top: height * 0.07,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Guess the Player',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          
                        ],
                      ),
                      SizedBox(
                        height: height * 0.009,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            userName != null
                                ? 'Welcome ' + userName['name'] + '!'
                                : '',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(width: 10),
                          country == null
                              ? Container()
                              : Image.network(
                                  'http://www.sciencekids.co.nz/images/pictures/flags680/$country.jpg',
                                  width: 20,
                                  height: 20,
                                )
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Divider(
                        height: 5.0,
                        color: Colors.white,
                      ),
                      Container(
                        height: height / 2,
                        width: width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/bg.jpg'),
                              fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: height * 0.14,
                        width: width * 0.9,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Colors.white),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Challenge your football friends and show them who si a real football fanatic!',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GamePage()));
                        },
                        child: Opacity(
                          opacity: _animation.value,
                          child: Container(
                            height: height * 0.1,
                            width: width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.lightBlueAccent,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Tap to Start',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
