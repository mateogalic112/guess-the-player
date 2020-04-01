import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:palyer_guessing_app/auth/auth.dart';
import 'package:palyer_guessing_app/game_logic/runout.dart';
import 'package:palyer_guessing_app/widgets/progress_painter.dart';

class GameTimer extends StatefulWidget {
  final int score;
  final int playerIndex; 
  final int lifeIndex;
  final bool resetAnimation;
  final VoidCallback onTimeRunOut;
  final VoidCallback showInterAd;

  GameTimer({@required this.score, @required this.playerIndex,
    @required this.resetAnimation, @required this.lifeIndex,
    @required this.onTimeRunOut, @required this.showInterAd});

  @override
  _GameTimerState createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer>
    with SingleTickerProviderStateMixin {
  double _percentage = 0;
  AnimationController _progressAnimationController;
  Animation<double> _progressAnimation;

  @override
  initState() {
    super.initState();
    _progressAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 46));
    _progressAnimation = Tween(begin: 46.0, end: 0.0)
        .animate(_progressAnimationController)..addListener(() {
          setState(() {
            _percentage = _progressAnimation.value;
            if(_percentage == 0 && widget.lifeIndex < 2) {
              widget.onTimeRunOut();
            } else if(_percentage == 0 && widget.lifeIndex == 2) {
              widget.showInterAd();
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => RunOut(score: widget.score, auth: Auth())
              ));
            }  
          });
        });
    _progressAnimationController.forward();
  }


  @override
  void didUpdateWidget (GameTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.playerIndex != widget.playerIndex) {
      _progressAnimationController.forward();
    }
    if(widget.resetAnimation == true) {
      _progressAnimationController.reset();
    }
  }



  getProgressText() {
    return Text(
      '${_percentage.toInt()}',
      style: TextStyle(
          fontSize: 35, fontWeight: FontWeight.w700, color: Colors.green),
    );
  }

  progressView() {
    return CustomPaint(
      child: Center(
        child: getProgressText(),
      ),
      foregroundPainter: ProgressPainter(
          defaultCircleColor: Colors.grey.withOpacity(0.5),
          percentageCompletedCircleColor: Colors.green,
          completedPercentage: _percentage,
          circleWidth: 6),
    );
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      padding: EdgeInsets.all(5),
      child: progressView(),
    );
  }
}
