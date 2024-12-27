class Explosion {
  int x;
  int y;
  int time;
  String playerId;

  Explosion(this.x, this.y, this.playerId, {int tickRate = 1}) : time = 3 * tickRate;
}