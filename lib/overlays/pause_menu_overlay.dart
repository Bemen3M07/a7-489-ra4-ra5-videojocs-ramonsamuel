import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';

// 4b11: Menú de pausa
class PauseMenuOverlay extends StatelessWidget {
  final SpaceShooterGame game;

  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'JOC EN PAUSA',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 40),
              _PauseButton(
                label: '▶ CONTINUAR',
                color: Colors.greenAccent,
                onTap: () => game.togglePause(),
              ),
              const SizedBox(height: 16),
              _PauseButton(
                label: '⚙ CONFIGURACIÓ',
                color: Colors.orangeAccent,
                onTap: () => game.overlays.add('Settings'),
              ),
              const SizedBox(height: 16),
              _PauseButton(
                label: '🏠 MENÚ PRINCIPAL',
                color: Colors.redAccent,
                onTap: () => game.returnToMenu(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PauseButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
