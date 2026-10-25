import unittest
from level_reachability import check_map,edge_reachable, RUN_SPEED,JUMP_SPEED,GRAVITY

P={'run_speed':RUN_SPEED,'jump_speed':JUMP_SPEED,'gravity':GRAVITY}

def platform(name, left,right,y=390):return {'id':name,'left':left,'right':right,'y':y}

class TestLevelReachability(unittest.TestCase):
    def test_safe_staircase(self):
        data={'physics':P,'surfaces':[platform('start',0,120),platform('ledge',190,260,340),platform('finish',310,450,390)],'start_surface':'start','finish_surface':'finish'}
        result=check_map(data)
        self.assertTrue(result['reachable'],result['errors'])
    def test_impossible_horizontal_gap(self):
        data={'physics':P,'surfaces':[platform('start',0,120),platform('finish',450,600)],'start_surface':'start','finish_surface':'finish'}
        self.assertFalse(check_map(data)['reachable'])
    def test_impossible_vertical_jump(self):
        self.assertFalse(edge_reachable(platform('start',0,120,390),platform('end',130,220,270)))
    def test_physics_must_match_actual_game(self):
        data={'physics':{**P,'jump_speed':10000},'surfaces':[platform('start',0,120),platform('finish',150,250)],'start_surface':'start','finish_surface':'finish'}
        self.assertFalse(check_map(data)['reachable'])
    def test_no_collision_surface_fails(self):
        self.assertFalse(check_map({'physics':P,'surfaces':[]})['reachable'])

if __name__=='__main__':unittest.main()
