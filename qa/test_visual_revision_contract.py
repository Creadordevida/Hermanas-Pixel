"""Checks estáticos de la revisión visual en curso. No sustituyen Flutter/Android."""
import unittest
from pathlib import Path
R=Path(__file__).resolve().parents[1]
MAIN=(R/'lib/main.dart').read_text(encoding='utf-8')
INTERIORS=(R/'tools/build_interiors_parallax_twc.py').read_text(encoding='utf-8')
FOOTBALL=(R/'tools/build_football_parallax_twc.py').read_text(encoding='utf-8')

class VisualRevisionContract(unittest.TestCase):
    def test_title_no_blur_bleed(self):
        title=MAIN.split('Widget _title() => Stack(',1)[0]
        self.assertNotIn("ImageFilter.blur(sigmaX: 32",title)
        self.assertIn('const ColoredBox(color: Color(0xff12334d))',title)
        self.assertIn('FittedBox(fit: BoxFit.contain',title)

    def test_logo_without_dark_rectangle(self):
        title=MAIN.split('Widget _title() => Stack(',1)[1].split('static const double mapArtWidth',1)[0]
        self.assertIn("twc_corporate_verified_091.png",title)
        self.assertNotIn("Color(0xa0092749)",title)

    def test_interior_detailed_sources_and_real_rooms(self):
        self.assertIn("montanas_ciudad_ciclo.png",INTERIORS)
        self.assertIn("arbolado_medio_ciclo.png",INTERIORS)
        self.assertIn("ASSETS/SRCS['school'][zone]",INTERIORS)
        self.assertNotIn("neutral=Image.open(ASSETS/'scenes/school.png')",INTERIORS)

    def test_dance_use_wider_source(self):
        self.assertIn("start=(0,385,770)[variant]",INTERIORS)

    def test_school_bully_has_real_idle_walk_and_attack_states(self):
        self.assertIn("final walkingNow=(foe.x-foe.lastRenderedX).abs() > .12;",MAIN)
        self.assertIn("else if (foe.kind=='bully')",MAIN)
        self.assertIn("walkingNow ? (1+(foe.t*7).floor()%2) : 0",MAIN)
        self.assertNotIn("foe.kind=='bully' && !foe.defeated ? .028*math.sin",MAIN)

    def test_breakdancer_has_intermediate_floor_transition(self):
        self.assertIn("foe.kind=='breakdancer'",MAIN)
        self.assertIn("foe.t < .24 ? 1",MAIN)
        self.assertIn("foe.t < .39 ? 2",MAIN)
        self.assertIn("foe.t < .53 ? 3",MAIN)
        self.assertIn("foe.t < .65 ? 2 : 1",MAIN)
        self.assertNotIn("foe.kind=='breakdancer' ? 3",MAIN)

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
