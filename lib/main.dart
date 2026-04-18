import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/space_shooter_game.dart';
import 'overlays/main_menu_overlay.dart';
import 'overlays/level_selector_overlay.dart';
import 'overlays/settings_overlay.dart';
import 'overlays/pause_menu_overlay.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/hud_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GorillesApp());
}

class GorillesApp extends StatelessWidget {
  const GorillesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gorilles i Platans',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const _GameScreen(),
    );
  }
}

class _GameScreen extends StatefulWidget {
  const _GameScreen();

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  // Una sola instància del joc per tota la sessió
  final SpaceShooterGame _game = SpaceShooterGame();

  @override
  Widget build(BuildContext context) {
    // 4b1: GameWidget connecta el joc Flame amb l'arbre de widgets de Flutter
    return GameWidget<SpaceShooterGame>(
      game: _game,

      // 4b8: loadingBuilder - es mostra mentre es carreguen els assets
      loadingBuilder: (context) => const Scaffold(
        backgroundColor: Color(0xFF0A1A0A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.greenAccent),
              SizedBox(height: 20),
              Text(
                'Carregant Gorilles i Plàtans...',
                style: TextStyle(color: Colors.greenAccent, fontSize: 16),
              ),
            ],
          ),
        ),
      ),

      // 4b8: backgroundBuilder - fons Flutter (sota el canvas del joc)
      backgroundBuilder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF061206), // verd jungla fosc
              Color(0xFF020802),
            ],
          ),
        ),
      ),

      // 4b8: overlayBuilderMap - mapa de totes les pantalles Flutter sobre el joc
      overlayBuilderMap: {
        'MainMenu': (context, game) => MainMenuOverlay(game: game),
        'LevelSelector': (context, game) => LevelSelectorOverlay(game: game),
        'Settings': (context, game) => SettingsOverlay(game: game),
        'PauseMenu': (context, game) => PauseMenuOverlay(game: game),
        'GameOver': (context, game) => GameOverOverlay(game: game),
        'HUD': (context, game) => HudOverlay(game: game),
      },

      // Overlay inicial: menú principal
      initialActiveOverlays: const ['MainMenu'],
    );
  }
}
