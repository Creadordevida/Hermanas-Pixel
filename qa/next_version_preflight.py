#!/usr/bin/env python3
"""Inventario HONESTO del cierre de la próxima versión; nunca aprueba arte solo.

Uso (sin Android ni GitHub Actions):
    python3 qa/next_version_preflight.py
    python3 qa/next_version_preflight.py --strict-assets

Lee únicamente recursos reales del checkout, sin fabricar evidencias.
Antes de generar arte, siempre refleja BLOQUEADO donde falte una imagen.
--strict-assets aborta antes de compilar si faltan recursos indispensables;
la aprobación artística y el test Android son puertas SEPARADAS.
"""
from __future__ import annotations
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "qa" / "NEXT_VERSION_PREFLIGHT.json"

def present(path):
    return (ROOT / path).is_file()

def png(path):
    target = ROOT / path
    return (target.is_file() and target.stat().st_size > 128
            and target.open("rb").read(8) == b"\x89PNG\r\n\x1a\n")

def resource_inventory():
    enemy = "assets/images/enemies_new/"
    six = ["estafeta_bull", "sanfermin_runner", "navarre_king",
           "robot", "supporter", "tourist"]
    art = {name: png(enemy + name + "_atlas.png") for name in six}
    original = [
        "breakdancer", "bully", "referee", "rival",
    ]
    classic = {
        k: all(png("assets/images/enemies/{}_{}.png".format(k, n))
               for n in range(6 if k in ("breakdancer", "referee") else 5))
        for k in original
    }
    school = {
        "{}_{}".format(z, n): png(
            "assets/images/interiors_parallax/school/z{}_panel_{}.png".format(z, n))
        for z in range(3) for n in range(9)
    }
    dance = {
        "{}_{}".format(z, n): png(
            "assets/images/interiors_parallax/dance/z{}_panel_{}.png".format(z, n))
        for z in range(3) for n in range(3)
    }
    f = "assets/images/chapter45/football_parallax/"
    football = {
        name: png(f + name)
        for name in ("montanas_ciudad_deportiva_ciclo.png",
                     "arbolado_deportivo_ciclo.png")
    }
    main = (ROOT / "lib/main.dart").read_text(encoding="utf-8")
    approval = dict(re.findall(
        r"'(cleaning_robot|rival_supporter|tipsy_tourist|navarre_king|"
        r"estafeta_bull|sanfermin_runner)'\s*:\s*(true|false)", main))
    return {
        "A_portada": {
            "panorama_20_9": png("assets/images/title_wide_20x9.png"),
            "logo_TWC_transparente": png("assets/images/twc_title_mark_clean.png"),
            "pruebas_dart_preparadas": present("test/adaptive_title_screen_test.dart"),
        },
        "B_colegio": {
            "paneles_reales": sum(school.values()),
            "paneles_esperados": len(school),
            "auditoria_recurso_preparada": present("qa/audit_school_visual_quality.py"),
        },
        "C_danza": {
            "paneles_reales": sum(dance.values()),
            "paneles_esperados": len(dance),
        },
        "D_futbol": {
            "fondos_reales": sum(football.values()),
            "fondos_esperados": len(football),
        },
        "E_enemigos_nuevos": {
            "atlas_reales": sum(art.values()), "atlas_esperados": len(art),
            "aprobaciones_artistic_as_en_codigo": approval,
            "aprobados": sum(value == "true" for value in approval.values()),
            "aprobados_esperados": 6,
        },
        "F_enemigos_clasicos": {
            "fuentes_presentes": sum(classic.values()),
            "fuentes_esperadas": len(classic),
            "scripts_de_retoque": present("tools/refine_four_classic_enemies.py"),
            "retoque_generado": present(
                "qa/art_review/four_existing_enemy_polish_state.json"),
            "contactos_antes_despues": sum(present(
                "qa/art_review/{}_original_vs_polished.png".format(k))
                for k in original),
            "contactos_esperados": len(original),
        },
        "G_integracion": {
            "pruebas_rendimiento_y_regresion": present("test/qa_render_capture_test.dart"),
            "compilacion_Android_verificada": False,
        },
    }

def missing_art(result):
    return [
        name for name, obj in result.items()
        if (
            name == "A_portada" and
            not (obj["panorama_20_9"] and obj["logo_TWC_transparente"])
        ) or (
            name == "B_colegio" and
            obj["paneles_reales"] < obj["paneles_esperados"]
        ) or (
            name == "C_danza" and
            obj["paneles_reales"] < obj["paneles_esperados"]
        ) or (
            name == "D_futbol" and
            obj["fondos_reales"] < obj["fondos_esperados"]
        ) or (
            name == "E_enemigos_nuevos" and
            (obj["atlas_reales"] < obj["atlas_esperados"] or
             obj["aprobados"] < obj["aprobados_esperados"])
        ) or (
            name == "F_enemigos_clasicos" and
            (obj["fuentes_presentes"] < obj["fuentes_esperadas"] or
             not obj["retoque_generado"] or
             obj["contactos_antes_despues"] < obj["contactos_esperados"])
        )
    ]

def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict-assets", action="store_true")
    args = parser.parse_args(argv)
    result = resource_inventory()
    blocked = missing_art(result)
    # Fundamental: only resource presence checks, NOT visual or runtime approval.
    report = {
        "source": "repository checkout, real filesystem",
        "claims": "NO artístico, NO Flutter, NO Android",
        "blocks": result,
        "missing_art_or_approval": blocked,
        "ready_for_android": False,
        "reason": "Requires real visual review, Flutter and Android sign-off",
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2, ensure_ascii=False),
                   encoding="utf-8")
    for name, value in result.items():
        print(name, json.dumps(value, ensure_ascii=False))
    print("BLOQUEADOS:", ", ".join(blocked) if blocked else
          "Ningún recurso ausente; la revisión artística aún es obligatoria.")
    print("NO se ha ejecutado Flutter ni construido un APK.")
    if args.strict_assets and blocked:
        return 2
    return 0

if __name__ == "__main__":
    sys.exit(main())
