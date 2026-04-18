import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/enemy.dart';
import '../components/explosion.dart';

// 4b1: SpaceShooterGame és el FlameGame principal.
// FlameGame implementa el GameLoop internament: crida update() i render()
// a cada frame automàticament via la integració amb Flutter's scheduler.
class SpaceShooterGame extends FlameGame with PanDetector, HasCollisionDetection {
  late Player player;
  late SpawnComponent _enemySpawner;
  late TextComponent _scoreText;
  late TextComponent _levelText;

  int score = 0;
  int level = 1;
  bool isGameOver = false;

  // Configuració (settings)
  bool soundEnabled = true;
  String difficulty = 'Normal';

  @override
  Color backgroundColor() => const Color(0xFF0A1A0A); // 4b10: fons verd fosc (jungla)

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Parallax background - estreles (es mantenen per profunditat visual)
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('stars_0.png'),
        ParallaxImageData('stars_1.png'),
        ParallaxImageData('stars_2.png'),
      ],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);

    // Jugador (gorilla)
    player = Player()
      ..position = Vector2(size.x / 2, size.y * 0.8)
      ..width = 60
      ..height = 80
      ..anchor = Anchor.center;
    add(player);

    // SpawnComponent per enemics - 4b5: generació d'elements
    _enemySpawner = SpawnComponent(
      factory: (index) => Enemy(speedMultiplier: _enemySpeedMultiplier)
        ..position = Vector2(Random().nextDouble() * size.x, -Enemy.enemySize),
      period: _spawnPeriod,
      selfPositioning: true,
    );
    add(_enemySpawner);

    // HUD: puntuació
    _scoreText = TextComponent(
      text: 'Punts: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_scoreText);

    // HUD: nivell
    _levelText = TextComponent(
      text: 'Nivell: $level',
      position: Vector2(10, 38),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 16,
        ),
      ),
    );
    add(_levelText);
  }

  double get _enemySpeedMultiplier {
    switch (difficulty) {
      case 'Facil':
        return level == 1 ? 0.7 : level == 2 ? 1.0 : 1.3;
      case 'Dificil':
        return level == 1 ? 1.5 : level == 2 ? 2.0 : 2.5;
      default: // Normal
        return level == 1 ? 1.0 : level == 2 ? 1.5 : 2.0;
    }
  }

  double get _spawnPeriod {
    final base = difficulty == 'Facil' ? 1.5 : difficulty == 'Dificil' ? 0.6 : 1.0;
    return base / (level * 0.8 + 0.2);
  }

  void addScore(int points) {
    score += points;
    _scoreText.text = 'Punts: $score';
  }

  void spawnExplosion(Vector2 position) {
    add(Explosion(position: position));
  }

  // 4b11: Pausa del joc
  void togglePause() {
    if (paused) {
      resumeEngine();
      overlays.remove('PauseMenu');
    } else {
      pauseEngine();
      overlays.add('PauseMenu');
    }
  }

  void triggerGameOver() {
    if (isGameOver) return;
    isGameOver = true;
    pauseEngine();
    overlays.add('GameOver');
  }

  void startGame(int selectedLevel) {
    level = selectedLevel;
    isGameOver = false;
    score = 0;
    overlays.remove('MainMenu');
    overlays.remove('LevelSelector');
    overlays.remove('Settings');
    overlays.add('HUD');
    resumeEngine();
    // Reinicialitza components
    removeWhere((c) => c is! ParallaxComponent);
    _initGameComponents();
  }

  Future<void> _initGameComponents() async {
    player = Player()
      ..position = Vector2(size.x / 2, size.y * 0.8)
      ..width = 60
      ..height = 80
      ..anchor = Anchor.center;
    add(player);

    _enemySpawner = SpawnComponent(
      factory: (index) => Enemy(speedMultiplier: _enemySpeedMultiplier)
        ..position = Vector2(Random().nextDouble() * size.x, -Enemy.enemySize),
      period: _spawnPeriod,
      selfPositioning: true,
    );
    add(_enemySpawner);

    _scoreText = TextComponent(
      text: 'Punts: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_scoreText);

    _levelText = TextComponent(
      text: 'Nivell: $level',
      position: Vector2(10, 38),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 16,
        ),
      ),
    );
    add(_levelText);
  }

  void returnToMenu() {
    isGameOver = false;
    score = 0;
    pauseEngine();
    overlays.removeAll(['GameOver', 'PauseMenu', 'HUD']);
    overlays.add('MainMenu');
    removeWhere((c) => c is! ParallaxComponent);
  }

  // 4b1/4b2: FlameGame gestiona el GameLoop internament.
  // update(dt) i render(canvas) són cridats automàticament a cada frame.
  // Els components fills implementen els seus propis update/render.

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!paused && !isGameOver) {
      player.move(info.delta.global);
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (!paused && !isGameOver) {
      player.startShooting();
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }
}
