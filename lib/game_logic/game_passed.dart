import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:palyer_guessing_app/auth/auth.dart';
import 'package:palyer_guessing_app/models/player_model.dart';
import 'package:palyer_guessing_app/pages/leaderboad.dart';
import 'package:palyer_guessing_app/pages/root_page.dart';
import 'package:palyer_guessing_app/services/name.dart';

class GamePassed extends StatefulWidget {
  final BaseAuth auth;

  GamePassed({@required this.auth});

  @override
  _GamePassedState createState() => _GamePassedState();
}

class _GamePassedState extends State<GamePassed> {

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
      .updateData({'highscore': players.length - 2});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Congrats!'),
          centerTitle: true,
        ),
        backgroundColor: Colors.greenAccent.withOpacity(0.5),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "You have successfully completed this game!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Your score was: ',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${players.length - 2}',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                height: 50,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: IconButton(
                  onPressed: () {
                    updateHighscore(docId);
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => RootPage(auth: Auth(),)));
                  },
                  icon: Icon(
                    Icons.done,
                  ),
                  iconSize: 30,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 8),
              Text('Home'),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Container(
                height: 70,
                width: MediaQuery.of(context).size.width * 0.8,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text(
                    'Leaderboard', style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  onPressed: () {
                    updateHighscore(docId);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LeaderBoard()
                    ));
                  },
                ),
              ),
            ]));
  }
}
