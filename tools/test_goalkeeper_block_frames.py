"""Regression QA for goalkeeper attack animation: real visual dive must coincide with damage window."""
from pathlib import Path
from PIL import Image
import unittest,re
root=Path(__file__).resolve().parents[1]
main=(root/'lib/main.dart').read_text()

def pose(t):
    return 0 if t<.15 else 2 if t<.27 else 3 if t<.34 else 4 if t<.56 else 1

class KeeperDivingPose(unittest.TestCase):
    def test_dive_frame_is_selected_in_game_code(self):
        self.assertRegex(main,r"foe.kind=='goalkeeper'\s*\?\s*\(foe.t\s*<\s*\.15.*?foe.t\s*<\s*\.56\s*\?\s*4")
    def test_all_damage_window_uses_dive_frame(self):
        self.assertIn('foe.t >= .34 && foe.t < .52',main)
        for hundredth in range(34,52): self.assertEqual(pose(hundredth/100),4)
    def test_attacking_does_not_use_running_frames_only(self):
        self.assertEqual([pose(t) for t in (.0,.2,.3,.4,.65)],[0,2,3,4,1])
    def test_dive_sprite_anatomy_horizontal(self):
        upright=Image.open(root/'assets/images/enemies/goalkeeper_0.png').convert('RGBA')
        dive=Image.open(root/'assets/images/enemies/goalkeeper_4.png').convert('RGBA')
        a=upright.getchannel('A').getbbox();b=dive.getchannel('A').getbbox()
        self.assertGreater((b[2]-b[0])/(b[3]-b[1]), 2)
        self.assertGreater((a[3]-a[1])/(a[2]-a[0]), 1.5)
    def test_all_frames_maintain_floor_anchor_in_renderer(self):
        self.assertIn('groundY-actualHeight+airborne',main)
        self.assertIn("'goalkeeper' => 121.0",main)
    def test_instantaneous_dive_hit_box_not_changed(self):
        self.assertIn('if(absDist<52 && hero.y>groundY-60)',main)
        self.assertIn('foe.attackCooldown=2.7',main)
if __name__=='__main__': unittest.main()
