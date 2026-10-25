"""Grounded physical reachability bounds; no fabricated game passes."""
import unittest,math

INITIAL_JUMP_SPEED=410.0
GRAVITY=960.0
WALK_SPEED=169.0

def max_jump_height():return INITIAL_JUMP_SPEED**2/(2*GRAVITY)
def full_jump_duration():return 2*INITIAL_JUMP_SPEED/GRAVITY
def max_horizontal_reach():return WALK_SPEED*full_jump_duration()

class MovementBounds(unittest.TestCase):
    def test_conservative_jump_height_is_known(self):
        self.assertAlmostEqual(87.552,max_jump_height(),delta=.01)
    def test_horizontal_jumping_reach(self):
        self.assertAlmostEqual(144.35,max_horizontal_reach(),delta=.1)
    def test_no_level_may_use_untested_gaps(self):
        # Deliberately assert physical limits only: actual 7 level paths do NOT exist in verified form.
        self.assertLess(max_horizontal_reach(),150)

if __name__=='__main__':unittest.main()
