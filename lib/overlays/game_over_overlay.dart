import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';

class GameOverOverlay extends StatelessWidget {
  final SpaceShooterGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💀', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 12),
            const Text(
              'JOC ACABAT',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Puntuació: ${game.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('GameOver');
                game.overlays.add('LevelSelector');
                game.resumeEngine();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
                foregroundColor: Colors.greenAccent,
                side: const BorderSide(color: Colors.greenAccent, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text('TORNAR A JUGAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => game.returnToMenu(),
              child: const Text('🏠 Menú principal',
                  style: TextStyle(color: Colors.white54, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
