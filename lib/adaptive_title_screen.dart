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
      (sourceHeight * titleWideAspect).ceilToDouble();
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
  // Unapproved panorama is never needed for RC4 playtests.
  static const useApprovedWideArt =
      bool.fromEnvironment('TWC_TITLE_WIDE_APPROVED', defaultValue:false);
  static const cleanLogoAsset = 'assets/images/twc_title_mark_clean.png';

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
                child:action!=null
                    ? const SizedBox.expand()
                    : Container(
                        decoration:BoxDecoration(
                          color:Colors.black.withValues(alpha:.38),
                          borderRadius:BorderRadius.circular(10),
                        ),
                      ),
              )),
          ));
      return Stack(fit:StackFit.expand,children:[
        // The wide image must be built FROM the approved original, with its
        // central composition byte-for-byte untouched. Release QA forbids a
        // placeholder panorama; never mistake fallback for approved artwork.
        // Cover crops only EXTRA periphery within the certified 16:9-20:9
        // formats. No blurred strips, letterboxing or BoxFit.fill.
        // Full-width painted background, with the approved central 16:9
        // image drawn undistorted over it. No flat/black side bars.
        // One canonical illustration: never cover+overlay the same bitmap.
        // A matching painted surround preserves the entire 16:9 approved art
        // while respecting the panoramic viewport (no duplicate scenery).
        const Positioned.fill(child:Image(
          image:AssetImage('assets/images/title_wide_20x9_approved.webp'),
          fit:BoxFit.cover,
          alignment:Alignment.center,
          filterQuality:FilterQuality.high,
        )),
        if(g.canShowCentralUncropped) ...[
          button(g.newGame,'Nueva partida',onNewGame),
          button(g.continueGame,'Continuar',
              hasSavedGame?onContinue:null),
          if(!hasSavedGame)
            Positioned.fromRect(
              rect:g.originalRect(const Rect.fromLTWH(578,310,183,17)),
              child:IgnorePointer(child:Text(
                'Sin partida guardada',
                textAlign:TextAlign.center,
                style:TextStyle(color:Colors.white,
                  fontSize:11*g.scale,
                  shadows:const [Shadow(color:Colors.black,blurRadius:3)]),
              )),
            ),
        ],
        // Authentic TIKU TWC emblem. The wordmark and seal are rendered
        // transparently; there is no dark rectangular backing.
        Positioned.fromRect(rect:g.logo,child:IgnorePointer(
          child:Column(mainAxisAlignment:MainAxisAlignment.end,children:[
            Expanded(child:Image.asset(cleanLogoAsset,fit:BoxFit.contain,
              errorBuilder:(_, error, trace) => const SizedBox.shrink())),
            Text('THE WOLF COMPANY',
              textAlign:TextAlign.center,
              style:TextStyle(color:const Color(0xffffe2a1),
                fontSize:9*g.scale,fontWeight:FontWeight.w900,
                letterSpacing:1.5*g.scale,
                shadows:const [Shadow(color:Colors.black87,blurRadius:2)])),
            Text('MIREN & SARA SEAL OF APPROVAL',
              textAlign:TextAlign.center,
              style:TextStyle(color:const Color(0xffffe2a1),
                fontSize:5.5*g.scale,fontWeight:FontWeight.w600,
                letterSpacing:.5*g.scale,
                shadows:const [Shadow(color:Colors.black87,blurRadius:2)])),
          ]),
        )),
      ]);
    },
  );
}
