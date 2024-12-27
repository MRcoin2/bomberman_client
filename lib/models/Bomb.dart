class Bomb {
  String ownerId;
  int x;
  int y;
  int range = 2;
  int fuse;

  Bomb(this.ownerId, this.x, this.y, {int tickRate = 1}) : fuse = 3 * tickRate;
}