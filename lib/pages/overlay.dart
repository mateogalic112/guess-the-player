import 'package:flutter/material.dart';
import 'package:palyer_guessing_app/models/player_model.dart';

class OverlayPage extends StatefulWidget {

  final VoidCallback onTap;
  final int playerIndex;
  final bool isCorrect;

  OverlayPage({@required this.onTap, @required this.playerIndex, @required this.isCorrect});

  @override
  _OverlayPageState createState() => _OverlayPageState();
}

class _OverlayPageState extends State<OverlayPage> with SingleTickerProviderStateMixin{

  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500), vsync: this
    );
    _animation = Tween(begin: 0.1, end: 1.0).animate(_animationController)
    ..addListener(() {
      setState(() {

      });
    })..addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        _animationController.reverse();
      }
      else if(status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        widget.onTap();
      },
      child: Material(
        child: Container(
          height: height,
          width: width,
          color: Colors.greenAccent.withOpacity(0.7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.network(
                players[widget.playerIndex].imgPath, 
                width: width * 0.8, 
                height: height * 0.45,
                fit: BoxFit.cover,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              widget.isCorrect == true ? Text(
                "Correct!", style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green
                ),
                ) :
                Text(
                "The player was ${players[widget.playerIndex].name}", style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red
                ),
                ),
              SizedBox(height: 10),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isCorrect == true ? Colors.green :  Colors.red
                ),
                child: Icon(
                  widget.isCorrect == true ? Icons.done : Icons.close,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Opacity(
                opacity: _animation.value,
                  child: Text(
                  'Tap anywhere to continue', style: TextStyle(
                    fontSize: 15
                  ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}