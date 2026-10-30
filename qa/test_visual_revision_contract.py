"""Checks estáticos de la revisión visual en curso. No sustituyen Flutter/Android."""
import unittest
from pathlib import Path
R=Path(__file__).resolve().parents[1]
MAIN=(R/'lib/main.dart').read_text(encoding='utf-8')
INTERIORS=(R/'tools/build_interiors_parallax_twc.py').read_text(encoding='utf-8')
FOOTBALL=(R/'tools/build_football_parallax_twc.py').read_text(encoding='utf-8')

class VisualRevisionContract(unittest.TestCase):
    def test_title_no_blur_bleed(self):
        # Portada actual: componente AdaptiveTitleScreen, NO el viejo Stack.
        title=(R/'lib/adaptive_title_screen.dart').read_text()
        self.assertIn('AdaptiveTitleScreen',MAIN)
        self.assertIn('screen==Screen.title && resourcesReady && loadError==null',MAIN)
        self.assertIn('BoxFit.cover',title)
        self.assertNotIn('ImageFilter.blur(sigmaX: 32',title)
        self.assertIn('FittedBox(fit: BoxFit.contain',MAIN)  # gameplay only

    def test_logo_without_dark_rectangle(self):
        title=(R/'lib/adaptive_title_screen.dart').read_text()
        self.assertIn('cleanLogoAsset',title)
        self.assertIn('MIREN & SARA SEAL OF APPROVAL',title)
        self.assertNotIn('Color(0xa0092749)',title)

    def test_interior_detailed_sources_and_real_rooms(self):
        self.assertIn("montanas_ciudad_ciclo.png",INTERIORS)
        self.assertIn("arbolado_medio_ciclo.png",INTERIORS)
        self.assertIn("ASSETS/SRCS['school'][source_zone]",INTERIORS)
        self.assertNotIn("neutral=Image.open(ASSETS/'scenes/school.png')",INTERIORS)

    def test_dance_preserves_original_proportions(self):
        self.assertIn('sw,sh=1200,390',INTERIORS)
        self.assertIn('if abs(TILE_W/sw-H/sh)>1e-10:',INTERIORS)
        self.assertNotIn("start=(0,385,770)[variant]",INTERIORS)

    def test_classic_enemy_states_use_active_pose_module(self):
        # Animations moved to classic_enemy_pose.dart: old checks of inline
        # enemy animation branches in main.dart were guaranteed false.
        classic=(R/'lib/classic_enemy_pose.dart').read_text(encoding='utf-8')
        self.assertIn("import 'classic_enemy_pose.dart';",MAIN)
        self.assertIn('frame=classicEnemyFrame(',MAIN)
        self.assertIn('final walkingNow=(foe.x-foe.lastRenderedX).abs() > .12;',MAIN)
        self.assertIn("if (kind == 'bully')",classic)
        self.assertIn("return moving ? 1 + ((elapsed * 7).floor() % 2) : 0;",classic)
        self.assertIn("if (kind == 'breakdancer')",classic)
        for mark in ('elapsed < .10','elapsed < .22','elapsed < .34',
                     'elapsed < .54','elapsed < .66'):
            self.assertIn(mark,classic)
        self.assertIn("if (kind == 'referee')",classic)
        self.assertNotIn("foe.kind=='bully' && !foe.defeated ? .028*math.sin",MAIN)

    def test_rival_sixth_prone_pose_integrated_across_pipeline(self):
        classic=(R/'lib/classic_enemy_pose.dart').read_text(encoding='utf-8')
        exporter=(R/'tools/export_sprite_bounds.py').read_text(encoding='utf-8')
        flutter_test=(R/'test/qa_four_classic_enemy_render_test.dart').read_text(encoding='utf-8')
        unit=(R/'test/classic_enemy_pose_test.dart').read_text(encoding='utf-8')
        self.assertIn("if (defeated) return kind=='rival' ? 5 : 4;",classic)
        self.assertIn("v=='referee' || v=='breakdancer' || v=='rival'",MAIN)
        self.assertIn("('referee','breakdancer','rival')",exporter)
        self.assertIn("kind=='referee' || kind=='breakdancer' || kind=='rival'",flutter_test)
        self.assertIn("kind=='rival'?5:4",unit)
        self.assertTrue((R/'assets/images/enemies/rival_5.png').is_file())

    def test_navarre_king_replaces_old_statue_and_coins(self):
        self.assertNotIn("'statue'", MAIN)
        self.assertIn("'navarre_king'", MAIN)
        self.assertIn("paths['enemy_navarre_king_atlas']", MAIN)
        self.assertIn("if(foe.kind=='navarre_king')", MAIN)
        self.assertIn("foe.kingAwakeAt", MAIN)
        self.assertIn("foe.kingImpactDelivered", MAIN)
        self.assertIn("foe.kingAttackAt=time", MAIN)
        self.assertIn("hasApprovedEnemyArtwork('navarre_king') && stage == 3", MAIN)
        self.assertIn("'navarre_king': false", MAIN)
        self.assertIn("'rival_supporter': false", MAIN)
        self.assertIn("enemies.add(Enemy(enemies.length,'navarre_king',stageWidth*.54))", MAIN)
        self.assertIn("final radius=(e-.35)*210;", MAIN)
        self.assertNotIn("'statue' => 139.0", MAIN)

    def test_football_transition_not_straight_line(self):
        self.assertIn("contour=(13 + 7*np.sin",FOOTBALL)
        self.assertNotIn("for y in range(22):band[y,:,3]",FOOTBALL)


    def test_estafeta_encierro_nuevos_personajes_bloqueados_hasta_arte_real(self):
        self.assertIn("'estafeta_bull': false", MAIN)
        self.assertIn("'sanfermin_runner': false", MAIN)
        self.assertIn("if (stage == 2)", MAIN)
        self.assertIn("hasApprovedEnemyArtwork('estafeta_bull')", MAIN)
        self.assertIn("hasApprovedEnemyArtwork('sanfermin_runner')", MAIN)
        self.assertIn("if (foe.estafetaNew)", MAIN)
        self.assertIn("foe.kind=='estafeta_bull'", MAIN)

if __name__=='__main__':
    unittest.main()
