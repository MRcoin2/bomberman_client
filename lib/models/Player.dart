import 'package:flutter/material.dart';

class Player {
  final String name;
  final String id;
  int? lives;
  int score;
  int? bombPower;
  int? bombLimit;
  int? speed;
  double? x;
  double? y;
  bool isReady;
  int invincibilityTicks;
  bool get isAlive => lives! > 0;
  Color playerColor;



  Player ({
    required this.name,
    required this.id,
    this.lives,
    this.score = 0,
    this.bombLimit,
    this.bombPower,
    this.speed,
    this.x,
    this.y,
    this.isReady = false,
    this.invincibilityTicks = 0,
    required this.playerColor,
  });

}