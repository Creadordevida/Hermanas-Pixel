"""Prueba de contrato: cinco corazones, sin límites heredados de la 0.8.0.

No sustituye la prueba de widgets en Flutter; comprueba que la vida está
centralizada y que el daño, reinicio, mapa y HUD utilizan la misma regla.
"""
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def health_contract_ok(source, hearts_source, spec):
    required = (
        'hearts = maxHeroHearts',
        'hearts=maxHeroHearts;',
        'hearts=heartsAfterDamage(hearts);',
        'HeroHeartsRow(hearts:hearts',
        'HeroHeartsRow(hearts:maxHeroHearts',
    )
    return (
        spec.get('health_per_character') == 5
        and 'const int maxHeroHearts = 5;' in hearts_source
        and 'for (var index = 0; index < maxHeroHearts; index++)' in hearts_source
        and all(phrase in source for phrase in required)
        and 'hearts=2' not in source
        and "const Text('♥  ♥'" not in source
    )


class HealthContractTests(unittest.TestCase):
    def setUp(self):
        self.main = (ROOT / 'lib/main.dart').read_text()
        self.hearts = (ROOT / 'lib/hero_hearts.dart').read_text()
        self.spec = json.loads((ROOT / 'qa/specification_090.json').read_text())

    def test_five_lives_integrated_across_game(self):
        self.assertTrue(health_contract_ok(self.main,self.hearts,self.spec))

    def test_negative_detection_old_two_life_limit(self):
        self.assertFalse(health_contract_ok(self.main.replace('hearts=maxHeroHearts;','hearts=2;',1),self.hearts,self.spec))

    def test_negative_detection_missing_life_icon(self):
        self.assertFalse(health_contract_ok(self.main,self.hearts.replace('index < maxHeroHearts','index < 2'),self.spec))


if __name__ == '__main__':
    unittest.main()
