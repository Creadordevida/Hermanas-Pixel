"""Regresión del control honesto de recursos de la próxima versión.

No requiere Flutter ni llama a GitHub Actions.
"""
import unittest
from qa.next_version_preflight import missing_art

class NextVersionGateTest(unittest.TestCase):
    def setUp(self):
        self.healthy = {
            "A_portada": {"panorama_20_9":True,"logo_TWC_transparente":True},
            "B_colegio": {"paneles_reales":27,"paneles_esperados":27},
            "C_danza": {"paneles_reales":9,"paneles_esperados":9},
            "D_futbol": {"fondos_reales":2,"fondos_esperados":2},
            "E_enemigos_nuevos": {
                "atlas_reales":6,"atlas_esperados":6,
                "aprobados":6,"aprobados_esperados":6,
            },
            "F_enemigos_clasicos": {
                "fuentes_presentes":4,"fuentes_esperadas":4,
                "retoque_generado":True,
                "contactos_antes_despues":4,"contactos_esperados":4,
            },
            "G_integracion": {"compilacion_Android_verificada":False},
        }

    def test_unverified_android_remains_separate_from_asset_presence(self):
        self.assertEqual(missing_art(self.healthy), [])

    def test_six_enemies_blocked_even_if_atlases_exist(self):
        self.healthy["E_enemigos_nuevos"]["aprobados"]=0
        self.assertIn("E_enemigos_nuevos",missing_art(self.healthy))

    def test_missing_title_art_blocks_release(self):
        self.healthy["A_portada"]["panorama_20_9"]=False
        self.assertIn("A_portada",missing_art(self.healthy))

    def test_missing_school_panels_are_not_counted_as_valid(self):
        self.healthy["B_colegio"]["paneles_reales"]=26
        self.assertIn("B_colegio",missing_art(self.healthy))

    def test_original_classic_art_does_not_count_as_refined(self):
        self.healthy["F_enemigos_clasicos"]["retoque_generado"]=False
        self.assertIn("F_enemigos_clasicos", missing_art(self.healthy))
        self.healthy["F_enemigos_clasicos"]["retoque_generado"]=True
        self.healthy["F_enemigos_clasicos"]["contactos_antes_despues"]=3
        self.assertIn("F_enemigos_clasicos", missing_art(self.healthy))

    def test_multiple_independent_blockers_are_reported(self):
        self.healthy["A_portada"]["logo_TWC_transparente"]=False
        self.healthy["E_enemigos_nuevos"]["atlas_reales"]=5
        self.healthy["C_danza"]["paneles_reales"]=8
        self.assertEqual(set(missing_art(self.healthy)),
                         {"A_portada","E_enemigos_nuevos","C_danza"})

if __name__=="__main__":
    unittest.main()
