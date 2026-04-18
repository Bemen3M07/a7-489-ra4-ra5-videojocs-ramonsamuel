import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';

// 4b12: Pantalla d'inici del joc
class MainMenuOverlay extends StatelessWidget {
  final SpaceShooterGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🦍', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 8),
              const Text(
                'GORILLES & PLÀTANS',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Space Shooter',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 48),
              _MenuButton(
                label: 'JUGAR',
                color: Colors.greenAccent,
                onTap: () {
                  game.overlays.remove('MainMenu');
                  game.overlays.add('LevelSelector');
                },
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'CONFIGURACIÓ',
                color: Colors.orangeAccent,
                onTap: () {
                  game.overlays.remove('MainMenu');
                  game.overlays.add('Settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
