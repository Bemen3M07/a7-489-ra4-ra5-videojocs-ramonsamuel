import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';

// 4b12: Pantalla de configuració
class SettingsOverlay extends StatefulWidget {
  final SpaceShooterGame game;

  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  @override
  Widget build(BuildContext context) {
    // Material és necessari per Switch i SegmentedButton dins els overlays de Flame
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.9),
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2010),
              border: Border.all(color: Colors.greenAccent, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CONFIGURACIÓ',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 28),

                // So
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'So activat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Switch(
                      value: widget.game.soundEnabled,
                      activeThumbColor: Colors.greenAccent,
                      onChanged: (val) =>
                          setState(() => widget.game.soundEnabled = val),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),

                // Dificultat
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Dificultat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Facil', label: Text('Fàcil')),
                    ButtonSegment(value: 'Normal', label: Text('Normal')),
                    ButtonSegment(value: 'Dificil', label: Text('Difícil')),
                  ],
                  selected: {widget.game.difficulty},
                  onSelectionChanged: (sel) =>
                      setState(() => widget.game.difficulty = sel.first),
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? Colors.black
                          : Colors.white,
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? Colors.greenAccent
                          : Colors.transparent,
                    ),
                  ),
                ),

                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    widget.game.overlays.remove('Settings');
                    widget.game.overlays.add('MainMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.greenAccent,
                    side: const BorderSide(color: Colors.greenAccent, width: 2),
                  ),
                  child: const Text('GUARDAR I TORNAR'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
