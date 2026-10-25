import 'package:flutter/material.dart';

/// Vida máxima de las dos protagonistas. Usar esta constante en todos los
/// reinicios, reintentos y representaciones de la interfaz.
const int maxHeroHearts = 5;

/// Un golpe quita un corazón. Nunca permite vida negativa o mayor al máximo.
/// La invulnerabilidad tras el golpe se gestiona en el motor de juego.
int heartsAfterDamage(int current) => (current - 1).clamp(0, maxHeroHearts).toInt();

/// Indicador estable: dibuja SIEMPRE cinco posiciones, llenas o vacías.
/// Su tamaño compacto evita tapar el nombre del capítulo en horizontal.
class HeroHeartsRow extends StatelessWidget {
  const HeroHeartsRow({super.key, required this.hearts, this.iconSize = 18});
  final int hearts;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final safeHearts = hearts.clamp(0, maxHeroHearts).toInt();
    return Semantics(
      label: 'Vida: $safeHearts de $maxHeroHearts corazones',
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var index = 0; index < maxHeroHearts; index++)
          Padding(
            padding: EdgeInsets.only(right: index == maxHeroHearts - 1 ? 0 : 1),
            child: Icon(
              index < safeHearts ? Icons.favorite : Icons.favorite_border,
              key: Key('heart-slot-$index'),
              color: index < safeHearts
                  ? const Color(0xffff6373)
                  : const Color(0xffe3b7bd),
              size: iconSize,
            ),
          ),
      ]),
    );
  }
}
