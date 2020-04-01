
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:palyer_guessing_app/auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:palyer_guessing_app/pages/game_page.dart';
import 'package:palyer_guessing_app/pages/leaderboad.dart';
import '../services/name.dart';

class RunOut extends StatefulWidget {
  final int score;
  final BaseAuth auth;

  RunOut({this.score, @required this.auth});

  @override
  _RunOutState createState() => _RunOutState();
}

class _RunOutState extends State<RunOut> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  var userHighscore;
  List<DocumentSnapshot> docId;

  getHighscore() {
   widget.auth.currentUser().then((userId) {
      FirebaseQuery().getNameQuery(userId).then((value) {
        docId = value.documents;
        if(value.documents.isNotEmpty) {
          userHighscore = value.documents[0].data;
        } else {
          print('Error');
        }
    });
    });
  }

  updateHighscore(List<DocumentSnapshot> docId) async {
    await Firestore.instance.collection('Users')
      .document(docId[0].documentID)
      .updateData({'highscore': widget.score});
  }


  @override
  void initState() {

    getHighscore();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    _animation = Tween(begin: 0.5, end: 1.0).animate(_controller)
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
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Game Over'),
      ),
      backgroundColor: Colors.greenAccent.withOpacity(0.5),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Text(
                    'Highscore: ', style: TextStyle(
                      fontSize: 30
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                  userHighscore != null ? userHighscore['highscore'].toString()
                  : '',
                  style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w700),
                ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                'Sorry, you ran out of',
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(height: 10),
              Text(
                'guesses!',
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Your score was:',
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${widget.score}',
                    style: TextStyle(fontSize: 40),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Divider(
                    height: 5,
                    color: Colors.grey,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Opacity(
                opacity: _animation.value,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GamePage()
                                  ));
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                    splashColor: Colors.blueAccent,
                    child: Text('Try Again'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.7,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.red[900].withOpacity(0.75),
                  textColor: Colors.black,
                  child: Text(
                    'Submit Score',
                  ),
                  onPressed: () {
                    if(widget.score > userHighscore['highscore']) {
                      updateHighscore(docId);
                      getHighscore();
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.6,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text(
                    'Leaderboard'
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LeaderBoard()
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
