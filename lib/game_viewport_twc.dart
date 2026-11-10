import 'dart:ui';

/// Fill landscape phones by revealing more world, not stretching sprites.
class GameViewportTWC {
  const GameViewportTWC(this.window);
  final Size window;
  static const double baseWidth=800;
  static const double baseHeight=450;
  double get aspect => window.height>0 ? window.width/window.height : 16/9;
  double get worldWidth => aspect < 16/9 ? baseWidth : baseHeight*aspect;
  double get scale => window.height>0 ? window.height/baseHeight : 1;
  double get outputWidth => worldWidth*scale;
  bool get hasHorizontalGutters => (outputWidth-window.width).abs()>.1;
  double worldXFromScreen(double x)=>x/scale;
  double screenXFromWorld(double x)=>x*scale;
}
