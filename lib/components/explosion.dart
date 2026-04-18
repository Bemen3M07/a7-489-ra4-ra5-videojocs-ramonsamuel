import 'package:flame/components.dart';
import '../game/space_shooter_game.dart';

// 4b4: SpriteAnimationComponent - reprodueix la animació d'explosió fotograma a fotograma
// explosion.png: 192x32px -> 6 frames de 32x32px
class Explosion extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Explosion({super.position})
      : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
          removeOnFinish: true, // s'auto-elimina en acabar
        );

  @override
  Future<void> onLoad() async {
    // 4b4: SpriteAnimation - defineix els fotogrames i la velocitat
    animation = await game.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false, // no repeteix, s'elimina en acabar
      ),
    );
  }
}
