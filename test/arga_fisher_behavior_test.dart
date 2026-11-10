import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/arga_fisher_behavior.dart';

void main() {
  test('fisher warns then emits one delayed hook cast', () {
    final fisher = ArgaFisherMotion(1200);
    expect(fisher.update(.016, 1300, playerVisible: true), isFalse);
    expect(fisher.pose, ArgaFisherPose.warning);
    for(var i=0;i<25;i++) {
      expect(fisher.update(.016, 1300, playerVisible: true), isFalse);
    }
    var casts=0;
    for(var i=0;i<90;i++) {
      if(fisher.update(.016,1300,playerVisible:true)) casts++;
    }
    expect(casts,1);
  });

  test('losing line of sight cancels warning', () {
    final fisher = ArgaFisherMotion(1200);
    fisher.update(.016,1300,playerVisible:true);
    expect(fisher.pose,ArgaFisherPose.warning);
    expect(fisher.update(.016,1300,playerVisible:false),isFalse);
    expect(fisher.pose,ArgaFisherPose.idle);
  });

  test('hit interrupts rod, defeat prevents further attacks', () {
    final fisher = ArgaFisherMotion(1200);
    fisher.update(.016,1300,playerVisible:true);
    fisher.hit();
    for(var i=0;i<35;i++) {
      expect(fisher.update(.016,1300,playerVisible:true),isFalse);
    }
    fisher.defeat();
    for(var i=0;i<120;i++) {
      expect(fisher.update(.016,1300,playerVisible:true),isFalse);
    }
    expect(fisher.pose,ArgaFisherPose.defeated);
    expect(fisher.x,1200);
  });
}
