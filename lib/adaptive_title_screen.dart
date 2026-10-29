import 'dart:math' as math;

import 'package:flutter/material.dart';

/// All coordinates refer to the approved 800x450 central composition.
/// No stretching or cropping of the title, sisters, cars or visible buttons.
const double titleArtWidth = 800;
const double titleArtHeight = 450;
const double titleWideAspect = 20 / 9;

@immutable
class TitleGeometry {
  const TitleGeometry(this.viewport);
  final Size viewport;

  /// Physical scale preserves the approved illustration's aspect ratio.
  double get scale => viewport.height / titleArtHeight;
  double get centralWidth => titleArtWidth * scale;
  double get insetX => (viewport.width - centralWidth) / 2;

  Rect originalRect(Rect source) => Rect.fromLTWH(
    insetX + source.left * scale, source.top * scale,
    source.width * scale, source.height * scale,
  );

  Rect get newGame => originalRect(const Rect.fromLTWH(551, 183, 208, 59));
  Rect get continueGame => originalRect(const Rect.fromLTWH(557, 249, 203, 61));

  Rect get logo => originalRect(const Rect.fromLTWH(280, 382, 240, 65));

  /// Source pixels to display from the wide 1000x450 panorama.
  /// On 16:9, exactly its unmodified central 800x450 area is shown;
  /// 18:9, 19.5:9 and 20:9 reveal progressively more peripheral scenery.
  Rect panoramaSource(Size panorama) {
    final availableRatio = viewport.width / viewport.height;
    final sourceRatio = panorama.width / panorama.height;
    if (availableRatio <= sourceRatio) {
      final sw = panorama.height * availableRatio;
      return Rect.fromLTWH((panorama.width - sw) / 2, 0, sw, panorama.height);
    }
    // Wider-than-20:9 devices get an explicit extension policy in QA.
    // No stretching is allowed, so visible vertical crop is unavoidable
    // until larger artwork exists. 20:9 is the largest certified format.
    final sh = panorama.width / availableRatio;
    return Rect.fromLTWH(0, (panorama.height - sh) / 2, panorama.width, sh);
  }

  /// The center fits if the device is at least 16:9 landscape.
  bool get canShowCentralUncropped =>
      viewport.width + .01 >= titleArtWidth * scale;

  static bool supportsAspect(Size viewport) {
    if (viewport.width <= 0 || viewport.height <= 0) return false;
    final aspect=viewport.width / viewport.height;
    return aspect >= 16 / 9 - .001 &&
           aspect <= titleWideAspect + .001;
  }

  static double recommendedPanoramaWidth(double sourceHeight) =>
      math.ceil(sourceHeight * titleWideAspect).toDouble();
}

/// Title rendering is isolated from the 800x450 GAMEPLAY FittedBox.
/// The backdrop fills the screen while the image buttons are hit-tested
/// using exactly the same central-space transformation.
class AdaptiveTitleScreen extends StatelessWidget {
  const AdaptiveTitleScreen({
    super.key,
    required this.onNewGame,
    required this.onContinue,
    required this.hasSavedGame,
  });

  final VoidCallback onNewGame;
  final VoidCallback onContinue;
  final bool hasSavedGame;

  static const panoramaAsset = 'assets/images/title_wide_20x9.png';
  static const cleanLogoAsset = 'assets/images/twc_logo_transparent_091.png';

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder:(context,constraints) {
      final size=Size(constraints.maxWidth,constraints.maxHeight);
      final g=TitleGeometry(size);
      Widget button(Rect area,String label,VoidCallback? action) =>
          Positioned.fromRect(rect:area,child:Semantics(
            label:label,
            button:true,
            enabled:action!=null,
            child:Material(color:Colors.transparent,
              child:InkWell(
                key:ValueKey(label=='Nueva partida'
                    ? 'title-new-game' : 'title-continue'),
                onTap:action,
                child:const SizedBox.expand(),
              )),
          ));
      return Stack(fit:StackFit.expand,children:[
        // The wide image is built FROM the approved original, with its
        // 800x450 central composition byte-for-byte untouched.
        // Cover crops only EXTRA periphery within the certified 16:9-20:9
        // formats. No blurred strips, letterboxing or BoxFit.fill.
        Image.asset(panoramaAsset,fit:BoxFit.cover,
          alignment:Alignment.center,
          errorBuilder:(_,_,_) => Image.asset(
            'assets/images/title_cars_fixed_091.png',
            fit:BoxFit.cover,alignment:Alignment.center,
          ),
        ),
        if(g.canShowCentralUncropped) ...[
          button(g.newGame,'Nueva partida',onNewGame),
          button(g.continueGame,'Continuar',
              hasSavedGame?onContinue:null),
          if(!hasSavedGame)
            Positioned.fromRect(
              rect:g.originalRect(const Rect.fromLTWH(578,310,183,17)),
              child:const IgnorePointer(child:Text(
                'Sin partida guardada',
                textAlign:TextAlign.center,
                style:TextStyle(color:Colors.white,fontSize:11,
                  shadows:[Shadow(color:Colors.black,blurRadius:3)]),
              )),
            ),
        ],
        Positioned.fromRect(rect:g.logo,child:IgnorePointer(
          child:Image.asset(cleanLogoAsset,fit:BoxFit.contain,
            errorBuilder:(_,_,_) => const SizedBox.shrink(),
          ),
        )),
      ]);
    },
  );
}
