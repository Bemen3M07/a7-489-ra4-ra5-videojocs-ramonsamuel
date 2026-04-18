import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/player.dart';
import '../components/enemy.dart';
import '../components/explosion.dart';
import '../components/bullet.dart';

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
  bool _gameStarted = false;
  bool _isTouching = false;

  static const double _keyboardSpeed = 300;

  // Configuració (settings)
  bool soundEnabled = true;
  String difficulty = 'Normal';

  @override
  Color backgroundColor() => const Color(0xFF0A1A0A); // 4b10: fons verd fosc

  @override
  Future<void> onLoad() async {
    await super.onLoad();

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

    // Jugador (gorilla) - creat una sola vegada
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

    _scoreText = TextComponent(
      text: 'Punts: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
    add(_scoreText);

    _levelText = TextComponent(
      text: 'Nivell: $level',
      position: Vector2(10, 38),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.yellowAccent, fontSize: 16),
      ),
    );
    add(_levelText);

    add(TextComponent(
      text: 'Arrossega o WASD/Fletxes per moure | Espai per disparar',
      position: Vector2(size.x / 2, size.y - 18),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
    ));

    pauseEngine(); // Espera que l'usuari seleccioni nivell
  }

  double get _enemySpeedMultiplier {
    switch (difficulty) {
      case 'Facil':  return level == 1 ? 0.7 : level == 2 ? 1.0 : 1.3;
      case 'Dificil': return level == 1 ? 1.5 : level == 2 ? 2.0 : 2.5;
      default:        return level == 1 ? 1.0 : level == 2 ? 1.5 : 2.0;
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

  void spawnExplosion(Vector2 pos) => add(Explosion(position: pos));

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
    _gameStarted = false;
    player.stopShooting();
    pauseEngine();
    overlays.add('GameOver');
  }

  void startGame(int selectedLevel) {
    level = selectedLevel;
    isGameOver = false;
    _gameStarted = true;
    score = 0;

    player.position = Vector2(size.x / 2, size.y * 0.8);
    player.stopShooting();

    children.whereType<Enemy>().toList().forEach((e) => e.removeFromParent());
    children.whereType<Bullet>().toList().forEach((b) => b.removeFromParent());
    children.whereType<Explosion>().toList().forEach((e) => e.removeFromParent());

    _enemySpawner.removeFromParent();
    _enemySpawner = SpawnComponent(
      factory: (index) => Enemy(speedMultiplier: _enemySpeedMultiplier)
        ..position = Vector2(Random().nextDouble() * size.x, -Enemy.enemySize),
      period: _spawnPeriod,
      selfPositioning: true,
    );
    add(_enemySpawner);

    _scoreText.text = 'Punts: 0';
    _levelText.text = 'Nivell: $level';

    overlays.removeAll(['MainMenu', 'LevelSelector', 'Settings', 'GameOver']);
    overlays.add('HUD');
    resumeEngine();
  }

  void returnToMenu() {
    isGameOver = false;
    _gameStarted = false;
    _isTouching = false;
    player.stopShooting();
    pauseEngine();
    overlays.removeAll(['GameOver', 'PauseMenu', 'HUD']);
    overlays.add('MainMenu');
  }

  // 4b1/4b2: GameLoop - update és cridat a cada frame
  @override
  void update(double dt) {
    super.update(dt);
    if (_gameStarted && !paused && !isGameOver) {
      _handleKeyboardMovement(dt);
    }
  }

  void _handleKeyboardMovement(double dt) {
    // Llegeix tecles premudes directament de Flutter
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final delta = Vector2.zero();

    if (keys.contains(LogicalKeyboardKey.arrowLeft) || keys.contains(LogicalKeyboardKey.keyA)) {
      delta.x -= _keyboardSpeed * dt;
    }
    if (keys.contains(LogicalKeyboardKey.arrowRight) || keys.contains(LogicalKeyboardKey.keyD)) {
      delta.x += _keyboardSpeed * dt;
    }
    if (keys.contains(LogicalKeyboardKey.arrowUp) || keys.contains(LogicalKeyboardKey.keyW)) {
      delta.y -= _keyboardSpeed * dt;
    }
    if (keys.contains(LogicalKeyboardKey.arrowDown) || keys.contains(LogicalKeyboardKey.keyS)) {
      delta.y += _keyboardSpeed * dt;
    }

    if (!delta.isZero()) player.move(delta);

    if (keys.contains(LogicalKeyboardKey.space)) {
      player.startShooting();
    } else if (!_isTouching) {
      player.stopShooting();
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (!paused && !isGameOver && _gameStarted) {
      _isTouching = true;
      player.startShooting();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!paused && !isGameOver && _gameStarted) {
      player.move(info.delta.global);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _isTouching = false;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    if (!keys.contains(LogicalKeyboardKey.space)) {
      player.stopShooting();
    }
  }
}
