import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';
import 'bullet.dart';

// 4b9: El jugador és un gorilla (substitueix la nau original)
// 4b3: PositionComponent proporciona position, size, scale, angle, anchor (visibility via isVisible)
class Player extends PositionComponent with HasGameReference<SpaceShooterGame> {
  late SpawnComponent _bulletSpawner;

  // 4b3: visibility - controla si el component es renderitza
  bool isVisible = true;

  // 4b3: scale - factor d'escala del component
  // (accessible via inherited scale property de PositionComponent)

  Player() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Hitbox per detecció de col·lisions
    add(RectangleHitbox(
      size: Vector2(40, 60),
      anchor: Anchor.center,
      position: Vector2(width / 2, height / 2),
    ));

    // SpawnComponent per bales (plàtans) - 4b5: generació d'elements
    _bulletSpawner = SpawnComponent(
      factory: (index) => Bullet(
        position: absolutePosition - Vector2(0, height / 2),
      ),
      period: 0.25,
      selfPositioning: true,
      autoStart: false,
    );
    game.add(_bulletSpawner);
  }

  void move(Vector2 delta) {
    // 4b3: position - Vector2 amb coordenades x,y del component
    position += delta;
    // Limita el gorilla dins de la pantalla
    position.x = position.x.clamp(width / 2, game.size.x - width / 2);
    position.y = position.y.clamp(height / 2, game.size.y - height / 2);
  }

  void startShooting() => _bulletSpawner.timer.start();
  void stopShooting() => _bulletSpawner.timer.stop();

  // 4b2: render - dibuixa el gorilla al Canvas a cada frame
  @override
  void render(Canvas canvas) {
    if (!isVisible) return;
    _drawGorilla(canvas);
  }

  void _drawGorilla(Canvas canvas) {
    final cx = width / 2;
    final cy = height / 2;

    // Braços
    final armPaint = Paint()..color = const Color(0xFF5D3A1A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, cy - 10, 10, 30),
        const Radius.circular(5),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width - 10, cy - 10, 10, 30),
        const Radius.circular(5),
      ),
      armPaint,
    );

    // Cos
    final bodyPaint = Paint()..color = const Color(0xFF6B4226);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 18, cy - 5, 36, 40),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Cap
    final headPaint = Paint()..color = const Color(0xFF7B5230);
    canvas.drawCircle(Offset(cx, cy - 15), 22, headPaint);

    // Cara (zona clara)
    final facePaint = Paint()..color = const Color(0xFFD2A679);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 12), width: 30, height: 25),
      facePaint,
    );

    // Ulls
    final eyeWhite = Paint()..color = Colors.white;
    final eyeBlack = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx - 8, cy - 20), 6, eyeWhite);
    canvas.drawCircle(Offset(cx + 8, cy - 20), 6, eyeWhite);
    canvas.drawCircle(Offset(cx - 7, cy - 20), 3, eyeBlack);
    canvas.drawCircle(Offset(cx + 9, cy - 20), 3, eyeBlack);

    // Nas
    final nosePaint = Paint()..color = const Color(0xFF4A2C0A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 10), width: 12, height: 7),
      nosePaint,
    );

    // Celles expressives
    final browPaint = Paint()
      ..color = const Color(0xFF3A1A00)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final browPath = Path();
    browPath.moveTo(cx - 14, cy - 27);
    browPath.quadraticBezierTo(cx - 8, cy - 31, cx - 2, cy - 27);
    canvas.drawPath(browPath, browPaint);
    final browPath2 = Path();
    browPath2.moveTo(cx + 2, cy - 27);
    browPath2.quadraticBezierTo(cx + 8, cy - 31, cx + 14, cy - 27);
    canvas.drawPath(browPath2, browPaint);

    // Boca
    final mouthPaint = Paint()
      ..color = const Color(0xFF3A1A00)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final mouthPath = Path();
    mouthPath.moveTo(cx - 6, cy - 4);
    mouthPath.quadraticBezierTo(cx, cy - 1, cx + 6, cy - 4);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  // 4b2: update - actualitza la lògica del jugador a cada frame
  @override
  void update(double dt) {
    super.update(dt);
    // Actualitza la posició del spawner de bales
    if (isMounted) {
      _bulletSpawner;
    }
  }

  @override
  void onRemove() {
    _bulletSpawner.removeFromParent();
    super.onRemove();
  }
}
