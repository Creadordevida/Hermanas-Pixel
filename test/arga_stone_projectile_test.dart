import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_stone_projectile.dart';

void main() {
  test('Stone travels in a gravity arc and expires at river water', () {
    final stone=ArgaStoneProjectile(originX:100,originY:230,targetX:250);
    final y0=stone.y;
    stone.advance(.2,waterY:440,heroCenterX:999,
      heroHalfWidth:20,heroTop:100,heroBottom:350);
    expect(stone.x,greaterThan(100));
    expect(stone.y,lessThan(y0));
    stone.advance(2,waterY:440,heroCenterX:999,
      heroHalfWidth:20,heroTop:100,heroBottom:350);
    expect(stone.active,isFalse);
  });

  test('Fast frame cannot tunnel through an actor', () {
    final stone=ArgaStoneProjectile(originX:100,originY:300,targetX:340);
    final hit=stone.advance(.8,waterY:440,heroCenterX:215,
      heroHalfWidth:20,heroTop:200,heroBottom:370);
    expect(hit,isTrue);
    expect(stone.delivered,isTrue);
    expect(stone.active,isFalse);
    expect(stone.advance(.2,waterY:440,heroCenterX:215,
      heroHalfWidth:20,heroTop:200,heroBottom:370),isFalse);
  });

  test('Passing above a ducking actor cannot hit', () {
    final stone=ArgaStoneProjectile(originX:100,originY:170,targetX:300);
    final hit=stone.advance(.5,waterY:440,heroCenterX:170,
      heroHalfWidth:15,heroTop:330,heroBottom:360);
    expect(hit,isFalse);
  });

  test('A defeated thrower cancels a pending stone', () {
    final stone=ArgaStoneProjectile(originX:100,originY:240,targetX:200);
    stone.cancel();
    expect(stone.advance(.7,waterY:440,heroCenterX:150,
      heroHalfWidth:25,heroTop:100,heroBottom:360),isFalse);
  });
}
