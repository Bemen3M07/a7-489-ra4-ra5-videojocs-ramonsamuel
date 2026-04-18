import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';
import 'bullet.dart';

// 4b9: L'enemic és un gorilla enemic (substitueix la nau enemiga)
// 4b3: PositionComponent - té position, size, scale, anchor, visibility
class Enemy extends PositionComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  static const double enemySize = 60;

  final double speedMultiplier;
  final double _baseSpeed = 250;

  Enemy({this.speedMultiplier = 1.0})
      : super(
          size: Vector2(enemySize, enemySize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Hitbox actiu per detectar col·lisions amb bales (actiu = comprova amb passius)
    add(RectangleHitbox());
  }

  // 4b2: update - mou l'enemic cap avall a cada frame
  @override
  void update(double dt) {
    super.update(dt);
    // 4b3: position - s'actualitza cada frame
    position.y += _baseSpeed * speedMultiplier * dt;
    if (position.y > game.size.y + enemySize) {
      removeFromParent();
      game.triggerGameOver();
    }
  }

  // 4b2: render - dibuixa el gorilla enemic al Canvas
  @override
  void render(Canvas canvas) {
    _drawEnemyGorilla(canvas);
  }

  void _drawEnemyGorilla(Canvas canvas) {
    final cx = width / 2;
    final cy = height / 2;

    // Cos (gorilla fosc/vermellós - aspecte amenaçant)
    final bodyPaint = Paint()..color = const Color(0xFF3B1A0A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 16, cy, 32, 25),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Braços
    final armPaint = Paint()..color = const Color(0xFF2A1008);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, cy + 2, 8, 20),
        const Radius.circular(4),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(width - 10, cy + 2, 8, 20),
        const Radius.circular(4),
      ),
      armPaint,
    );

    // Cap
    final headPaint = Paint()..color = const Color(0xFF4A2010);
    canvas.drawCircle(Offset(cx, cy - 2), 20, headPaint);

    // Cara
    final facePaint = Paint()..color = const Color(0xFF8B5A3A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 1), width: 26, height: 20),
      facePaint,
    );

    // Ulls vermells (enemic)
    final eyePaint = Paint()..color = const Color(0xFFFF3300);
    canvas.drawCircle(Offset(cx - 7, cy - 5), 5, eyePaint);
    canvas.drawCircle(Offset(cx + 7, cy - 5), 5, eyePaint);
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx - 6, cy - 5), 2, pupilPaint);
    canvas.drawCircle(Offset(cx + 8, cy - 5), 2, pupilPaint);

    // Nas
    final nosePaint = Paint()..color = const Color(0xFF1A0500);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 10, height: 6),
      nosePaint,
    );

    // Boca enfadada
    final mouthPaint = Paint()
      ..color = const Color(0xFF1A0500)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final mouthPath = Path();
    mouthPath.moveTo(cx - 6, cy + 10);
    mouthPath.quadraticBezierTo(cx, cy + 7, cx + 6, cy + 10);
    canvas.drawPath(mouthPath, mouthPaint);

    // Celles enfadades (inclinades cap al centre)
    final browPaint = Paint()
      ..color = const Color(0xFF1A0500)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(cx - 13, cy - 12), Offset(cx - 3, cy - 10), browPaint);
    canvas.drawLine(
        Offset(cx + 3, cy - 10), Offset(cx + 13, cy - 12), browPaint);
  }

  // 4b6: Col·lisió entre enemic i bala (plàtan)
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      game.spawnExplosion(position.clone());
      game.addScore(10);
      removeFromParent();
      other.removeFromParent();
    }
  }
}
