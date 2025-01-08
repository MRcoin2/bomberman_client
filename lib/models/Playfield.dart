import 'Block.dart';
import 'Wall.dart';
import 'Bomb.dart';
import 'Explosion.dart';
import 'Item.dart';
import 'Player.dart';

class Playfield {
  int width;
  int height;
  List<Block> blocks;
  List<Wall> walls;
  List<Bomb> bombs;
  List<Explosion> explosions;
  List<Item> items;
  Map<String, Player> players;

  Playfield(this.width, this.height)
      : blocks = [],
        walls = [],
        bombs = [],
        explosions = [],
        items = [],
        players = {};
}