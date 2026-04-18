import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_shooter_game.dart';

// 4b9: La bala és un plàtan (substitueix el projectil original)
// 4b3: PositionComponent - té position, size, scale, angle, anchor
class Bullet extends PositionComponent with HasGameReference<SpaceShooterGame> {
  static const double _speed = 500;

  Bullet({super.position})
      : super(
          size: Vector2(16, 30),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Hitbox passiu (millor rendiment quan hi ha molts projectils)
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  // 4b2: update - mou el plàtan cap amunt a cada frame
  @override
  void update(double dt) {
    super.update(dt);
    // 4b3: position - s'actualitza cada frame
    position.y -= _speed * dt;
    if (position.y < -height) removeFromParent();
  }

  // 4b2: render - dibuixa el plàtan al Canvas
  @override
  void render(Canvas canvas) {
    _drawBanana(canvas);
  }

  void _drawBanana(Canvas canvas) {
    final cx = width / 2;
    final cy = height / 2;

    // Cos del plàtan (forma corbada)
    final bananaYellow = Paint()..color = const Color(0xFFFFE135);
    final path = Path();
    path.moveTo(cx - 4, 2);
    path.quadraticBezierTo(cx + 8, cy, cx - 4, height - 2);
    path.quadraticBezierTo(cx - 10, cy, cx - 4, 2);
    canvas.drawPath(path, bananaYellow);

    // Puntes marrons
    final brownPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(Offset(cx - 4, 2), 3, brownPaint);
    canvas.drawCircle(Offset(cx - 4, height - 2), 3, brownPaint);

    // Reflexe lluminós
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final shinePath = Path();
    shinePath.moveTo(cx - 2, 6);
    shinePath.quadraticBezierTo(cx + 4, cy, cx - 2, height - 6);
    canvas.drawPath(shinePath, shinePaint);
  }
}
