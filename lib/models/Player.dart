class Player {
  final String name;
  final String id;
  int? lives;
  double? x;
  double? y;
  bool isReady;
  bool get isAlive => lives! > 0;



  Player ({
    required this.name,
    required this.id,
    this.lives,
    this.x,
    this.y,
    this.isReady = false,
  });

}