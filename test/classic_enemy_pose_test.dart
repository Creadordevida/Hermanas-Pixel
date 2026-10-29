import 'package:flutter_test/flutter_test.dart';
import '../lib/classic_enemy_pose.dart';

int f(String kind, {double t=0,bool moving=false,bool attacking=false,
    bool stunned=false,bool defeated=false,double distance=300,
    double cooldown=0})=>classicEnemyFrame(
  kind:kind,elapsed:t,moving:moving,attacking:attacking,
  stunned:stunned,defeated:defeated,
  heroDistance:distance,attackCooldown:cooldown,
);

void main() {
  const types=['breakdancer','bully','referee','rival'];

  test('all four remain still in authentic idle pose', () {
    for (final kind in types) {
      for (final t in [0.0,.8,2.3,12.0]) {
        expect(f(kind,t:t),0,reason:'$kind must not walk in place');
      }
    }
  });

  test('referee raises red card in distinct anticipated phases', () {
    expect(f('referee',t:.06,attacking:true),0);
    expect(f('referee',t:.24,attacking:true),1);
    expect(f('referee',t:.44,attacking:true),2);
    expect(f('referee',t:.65,attacking:true),3);
  });

  test('breakdancer follows grounded anatomical sequence', () {
    expect(f('breakdancer',t:.05,attacking:true),0);
    expect(f('breakdancer',t:.17,attacking:true),1);
    expect(f('breakdancer',t:.28,attacking:true),2);
    expect(f('breakdancer',t:.40,attacking:true),3);
    expect(f('breakdancer',t:.60,attacking:true),2);
  });

  test('rival uses all three authentic running poses when moving', () {
    final seen=<int>{};
    for (var i=0;i<20;i++) {
      seen.add(f('rival',t:i*.08,moving:true));
    }
    expect(seen,{1,2,3});
    expect(f('rival',t:.2,attacking:true,distance:35),3);
    expect(f('rival',t:.05,attacking:true,distance:35),2);
  });

  test('bully uses strong attack pose at close range, not while distant', () {
    expect(f('bully',t:.2,attacking:true,distance:40),3);
    expect(f('bully',t:.05,attacking:true,distance:40),2);
    expect(f('bully',distance:250,cooldown:1.5),0);
    expect(f('bully',t:.1,moving:true),inInclusiveRange(1,2));
  });

  test('hit and defeat override attacks for every enemy', () {
    for (final kind in types) {
      expect(f(kind,attacking:true,stunned:true),isNot(4));
      expect(f(kind,attacking:true,defeated:true),4);
      expect(f(kind,moving:true,stunned:true,defeated:true),4);
    }
  });
}
