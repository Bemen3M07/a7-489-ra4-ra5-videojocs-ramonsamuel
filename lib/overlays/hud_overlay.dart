import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';

// HUD visible durant la partida - conté el botó de pausa (4b11)
// Usa Stack+Positioned per no bloquejar els events de puntero del joc
class HudOverlay extends StatelessWidget {
  final SpaceShooterGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Capa transparent que ignora tots els events de puntero
        // perquè arribin al canvas del joc (fix: ratón/touch)
        const Positioned.fill(
          child: IgnorePointer(child: SizedBox.expand()),
        ),
        // Botó de pausa - únic element que captura events
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => game.togglePause(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      border: Border.all(color: Colors.greenAccent, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.pause,
                        color: Colors.greenAccent, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
