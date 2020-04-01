import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LeaderBoard extends StatefulWidget {
  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      color: Colors.greenAccent.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Stack(
          children: <Widget> [
            Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Name: ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '${doc.data['name']}',
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'Highscore: ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '${doc.data['highscore'].toString()}',
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: ClipOval(
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: (doc.data['userAvatar'] != null)
                            ? Image.network(
                                baseUrl + doc.data['userAvatar'] + baseUrl1,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/upit.png',
                                fit: BoxFit.cover,
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
      ),
    );
  }

  String baseUrl =
      'https://firebasestorage.googleapis.com/v0/b/player-guessing.appspot.com/o/';
  String baseUrl1 = '?alt=media&token=7a7bba46-9955-4860-8fb2-c0855f3694b5';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Material(
          color: Colors.greenAccent.withOpacity(0.5),
          child: Stack(
            children: <Widget>[
              Padding(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('Users')
                    .orderBy('highscore', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: snapshot.data.documents
                              .map((doc) =>
                                buildItem(doc)
                              )
                              .toList()
                              ),
                    );
                  } else {
                    return SizedBox(height: 10);
                  }
                },
              ),
            ),
            Positioned(
                top: 15,
                left: 100,
                child: Icon(
                  FontAwesomeIcons.crown,
                  color: Colors.yellow,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
