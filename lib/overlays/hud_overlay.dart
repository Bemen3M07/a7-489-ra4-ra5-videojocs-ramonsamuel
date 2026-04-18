import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';

// HUD visible durant la partida - conté el botó de pausa (4b11)
class HudOverlay extends StatelessWidget {
  final SpaceShooterGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => game.togglePause(), // 4b11: pausa
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                border: Border.all(color: Colors.greenAccent, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pause, color: Colors.greenAccent, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
