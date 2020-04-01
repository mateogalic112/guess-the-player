import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palyer_guessing_app/auth/auth.dart';
import 'package:palyer_guessing_app/game_logic/game_passed.dart';
import 'package:palyer_guessing_app/game_logic/runout.dart';
import 'package:palyer_guessing_app/models/player_model.dart';
import 'package:palyer_guessing_app/pages/overlay.dart';
import 'package:palyer_guessing_app/pages/root_page.dart';
import 'package:palyer_guessing_app/widgets/game_timer.dart';
import 'package:firebase_admob/firebase_admob.dart';


class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  int playerIndex = 0;
  int lifeIndex = 0;
  int currentHint;
  int hintIndex;
  int score;
  bool restartAnimation = false;
  bool isCorrect = true;

  bool visibleOverlay = false;
  bool showShadowOverlay = false;

  static String testDevice = 'D4DB6B6720896A5839E352C73CEE6BF1';
  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['soccer', 'quiz', 'players', 'fans']
  );

  InterstitialAd interstitialAd = InterstitialAd(
    adUnitId: 'ca-app-pub-2076054945841795/8032050419',
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("InterstitialAd $event");
    }
  );
  
  TextEditingController _textController = TextEditingController();

  Animation<double> _hintAnimation;
  AnimationController _hintController;

  Animation<double> _scoreAnimation;
  AnimationController _scoreController;

  Animation<double> _shadowOverlayAnimation;
  AnimationController _shadowOverlayController;

  _onClear() {
    setState(() {
      _textController.text = "";
    });
  }

  _showInterAd() {
    interstitialAd..load()..show();
  }

  _onTimeRunOut() {
    setState(() {
       _onClear();
      showShadowOverlay = true;
      _shadowOverlayController.forward();
        isCorrect = false;
        visibleOverlay = true;
        restartAnimation = true;
        lifeIndex++;
    });
  }

  _nextHintTap() {
    setState(() {
      _onClear();
      currentHint++;
      hintIndex++;
      if (currentHint > 5) {
        isCorrect = false;
        showShadowOverlay = true;
        _shadowOverlayController.forward();
        visibleOverlay = true;
        restartAnimation = true;
        lifeIndex++;
        currentHint = 1;
        hintIndex = 0;
      }
      if (lifeIndex > 2) {
        interstitialAd..show();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => RunOut(
                      score: score,
                      auth: Auth(),
                    )));
        return;
      }
      _hintController.reset();
      _hintController.forward();
    });
  }

  _onTap() {
    if(isCorrect) {
      setState(() {
       score++; 
      });
    }
    setState(() {
      _onClear();
      isCorrect = true;
      visibleOverlay = false;
      restartAnimation = false;
      showShadowOverlay = false;
      playerIndex++;
      if (playerIndex == (players.length - 2)) {
        visibleOverlay = false;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => GamePassed(auth: Auth())));
        return;
      }
      currentHint = 1;
      hintIndex = 0;
      _hintController.reset();
      _scoreController.forward();
      Future.delayed(Duration(milliseconds: 800), () {
        _hintController.forward();
      });
    });
  }

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-2076054945841795~4266945666');
    interstitialAd..load();
    currentHint = 1;
    hintIndex = 0;
    score = 0;
    print(players.length);

    players.shuffle();

    _shadowOverlayController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _shadowOverlayAnimation = Tween(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
            parent: _shadowOverlayController, curve: Curves.easeInOutCirc))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shadowOverlayController.reset();
          setState(() {
            showShadowOverlay = false;
          });
        }
      });

    _hintController =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    _hintAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _hintController, curve: Curves.decelerate))
      ..addListener(() {
        setState(() {});
      });

    Future.delayed(Duration(milliseconds: 700), () {
      _hintController.forward();
    });

    _scoreController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    _scoreAnimation = Tween(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.easeInOutBack))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scoreController.reset();
        }
      });

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _hintController.dispose();
    _scoreController.dispose();
    _shadowOverlayController.dispose();
    interstitialAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Guess the player'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => RootPage(
                          auth: Auth(),
                        )));
          },
        ),
      ),
      backgroundColor: Colors.greenAccent,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Score: $score',
                        style: TextStyle(
                            fontSize: 25 * _scoreAnimation.value,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.solidHeart,
                            color: lifeIndex == 0
                                ? Colors.red
                                : Colors.red.withOpacity(0.2),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            FontAwesomeIcons.solidHeart,
                            color: lifeIndex < 2
                                ? Colors.red
                                : Colors.red.withOpacity(0.2),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            FontAwesomeIcons.solidHeart,
                            color: lifeIndex < 3
                                ? Colors.red
                                : Colors.red.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                GameTimer(
                    score: score,
                    playerIndex: playerIndex,
                    lifeIndex: lifeIndex,
                    resetAnimation: restartAnimation,
                    onTimeRunOut: _onTimeRunOut,
                    showInterAd: _showInterAd),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Text('Hint number: ' + currentHint.toString() + '/5'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  height: 80,
                  width: width * 0.98,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.green,
                  ),
                  child: Padding(
                    padding: players[playerIndex].hints[hintIndex].length < 38
                        ? const EdgeInsets.symmetric(vertical: 24.0)
                        : const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 18),
                    child: hintIndex == 4 ? 
                    Image.network(players[playerIndex].hints[hintIndex]) 
                    : Text(
                      players[playerIndex].hints[hintIndex],
                      style: TextStyle(fontSize: _hintAnimation.value * 20),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 30,
                    ),
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Write player\'s name',
                      hintStyle: TextStyle(fontSize: 22),
                      suffix: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          iconSize: 15,
                          onPressed: _onClear,
                        ),
                      ),
                    ),
                    onSubmitted: (String value) {
                      String firstName = players[playerIndex].name.split(" ")[0].toLowerCase();
                      String lastName = players[playerIndex].name.split(" ")[1].toLowerCase();
                      if (value.toLowerCase() == firstName || value.toLowerCase() == lastName) {
                        setState(() {
                          visibleOverlay = true;
                          showShadowOverlay = true;
                          restartAnimation = true;
                          _shadowOverlayController.forward();
                        });
                      } else {
                        setState(() {
                          _onClear();
                          showShadowOverlay = true;
                          _shadowOverlayController.forward();
                          currentHint++;
                          hintIndex++;
                        if (currentHint > 5) {
                          setState(() {
                            isCorrect = false;
                            visibleOverlay = true;
                            restartAnimation = true;
                          });
                          lifeIndex++;
                          currentHint = 1;
                          hintIndex = 0;
                          if (lifeIndex > 2) {
                          interstitialAd..show();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RunOut(
                                        score: score,
                                        auth: Auth(),
                                      )));
                          return;
                        }
                        _hintController.reset();
                        _hintController.forward();
                        }
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    height: 70,
                    width: 70,
                    child: RaisedButton(
                      color: Colors.green,
                      onPressed: _nextHintTap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        'Next Hint',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            visibleOverlay == true
                ? OverlayPage(onTap: _onTap, playerIndex: playerIndex, isCorrect: isCorrect)
                : Container(),
            showShadowOverlay == true
                ? shadowOverlay(context, _shadowOverlayAnimation.value, isCorrect)
                : Container()
          ],
        ),
      ),
    );
  }

  Widget shadowOverlay(BuildContext context, double animValue, bool isCorrect) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Center(
      child: Opacity(
        opacity: animValue * 0.16,
        child: Container(
          height: height * animValue,
          width: width * animValue,
          color: isCorrect == false ? Colors.red[900] : Colors.green[900],
        ),
      ),
    );
  }
}
