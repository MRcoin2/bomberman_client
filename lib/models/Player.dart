class Player {
  final String name;
  final String id;
  int? lives;
  int? score;
  int? bombPower;
  int? bombLimit;
  double? speed;
  double? x;
  double? y;
  bool isReady;
  bool get isAlive => lives! > 0;



  Player ({
    required this.name,
    required this.id,
    this.lives,
    this.score,
    this.bombLimit,
    this.bombPower,
    this.speed,
    this.x,
    this.y,
    this.isReady = false,
  });

}