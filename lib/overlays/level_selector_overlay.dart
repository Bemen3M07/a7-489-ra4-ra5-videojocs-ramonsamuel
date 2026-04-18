import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';

// 4b12: Selector de nivell
class LevelSelectorOverlay extends StatelessWidget {
  final SpaceShooterGame game;

  const LevelSelectorOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SELECCIONA NIVELL',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            _LevelCard(
              level: 1,
              label: 'NIVELL 1',
              subtitle: 'Facil - 1 enemic/s',
              color: Colors.greenAccent,
              onTap: () => game.startGame(1),
            ),
            const SizedBox(height: 16),
            _LevelCard(
              level: 2,
              label: 'NIVELL 2',
              subtitle: 'Normal - 1.4 enemics/s',
              color: Colors.orangeAccent,
              onTap: () => game.startGame(2),
            ),
            const SizedBox(height: 16),
            _LevelCard(
              level: 3,
              label: 'NIVELL 3',
              subtitle: 'Dificil - 2 enemics/s',
              color: Colors.redAccent,
              onTap: () => game.startGame(3),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                game.overlays.remove('LevelSelector');
                game.overlays.add('MainMenu');
              },
              child: const Text(
                '← TORNAR',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              '$level',
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
