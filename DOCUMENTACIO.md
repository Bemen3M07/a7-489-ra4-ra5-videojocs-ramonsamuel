# Exercici 4 - Flutter Flame: Space Shooter (Gorilles i Plàtans)

**Autor:** Ramon Samuel Mascaro  
**Tutorial base:** [Space Shooter - Flame Engine](https://docs.flame-engine.org/latest/tutorials/space_shooter/space_shooter.html)  
**Joc escollit:** Space Shooter (6 passos implementats)

---

## 4b1 - GameWidget i GameLoop

### GameWidget
El **GameWidget** es troba a `lib/main.dart` (classe `_GameScreen`):
```dart
GameWidget<SpaceShooterGame>(
  game: _game,
  loadingBuilder: ...,
  backgroundBuilder: ...,
  overlayBuilderMap: {...},
  initialActiveOverlays: const ['MainMenu'],
)
```
`GameWidget` és el pont entre Flame i Flutter: integra el canvas del joc dins l'arbre de widgets de Flutter. Gestiona el cicle de vida del joc i els overlays.

### GameLoop
Flame **SÍ té GameLoop** intern. El `FlameGame` implementa el game loop via la integració amb el `SchedulerBinding` de Flutter. A cada frame:
1. **update(dt)** — actualitza la lògica (posicions, col·lisions, timers)
2. **render(canvas)** — dibuixa tots els components al Canvas

El GameLoop no és una classe explícita visible al codi, sinó que FlameGame el gestiona automàticament. La classe base `Game` implementa `tick(dt)` que crida `update` i `render` de forma encadenada.

---

## 4b2 - Render i Update del GameWidget

### Update
Cada component implementa `update(double dt)` on `dt` és el temps en segons des de l'últim frame:

- `Bullet.update(dt)` → `lib/components/bullet.dart:30` — mou el plàtan cap amunt: `position.y -= 500 * dt`
- `Enemy.update(dt)` → `lib/components/enemy.dart:38` — mou el gorilla enemic cap avall: `position.y += 250 * speedMultiplier * dt`
- `Player.update(dt)` → `lib/components/player.dart:125` — crida `super.update(dt)`

### Render
Cada component implementa `render(Canvas canvas)` que dibuixa el component al canvas de Flutter:

- `Player.render(canvas)` → `lib/components/player.dart:83` — dibuixa el gorilla jugador amb formes geomètriques (Canvas API)
- `Bullet.render(canvas)` → `lib/components/bullet.dart:37` — dibuixa el plàtan (banana shape)
- `Enemy.render(canvas)` → `lib/components/enemy.dart:47` — dibuixa el gorilla enemic

---

## 4b3 - Components: Visibility, Position, Size, Scale, Anchor

Tots els components principals hereten de `PositionComponent` de Flame, que proporciona:

| Propietat | Tipus | On s'usa | Descripció |
|-----------|-------|----------|------------|
| **position** | `Vector2` | `player.dart:63`, `enemy.dart:38`, `bullet.dart:30` | Coordenades x,y del component al món |
| **size** | `Vector2` | `bullet.dart:17`, `enemy.dart:30`, `explosion.dart:13` | Amplada i alçada del component |
| **scale** | `Vector2` | Heretat de `PositionComponent` | Factor d'escalat (1.0 = mida original) |
| **anchor** | `Anchor` | `player.dart:26`, `enemy.dart:30`, `explosion.dart:13` | Punt de referència (`Anchor.center` = centre) |
| **visibility** | `bool isVisible` | `player.dart:29` | Controla si el component es renderitza |

Exemple de `position` al `Player`:
```dart
position.x = position.x.clamp(width / 2, game.size.x - width / 2);
position.y = position.y.clamp(height / 2, game.size.y - height / 2);
```

**`angle`** (component addicional de `PositionComponent`): rotació en radians. No s'usa explícitament però és accessible a tots els components.

---

## 4b4 - SpriteComponent, Animation, AnimationGroup

### SpriteComponent
No s'usa directament `SpriteComponent` (que renderitza un sprite estàtic), sinó `SpriteAnimationComponent` per tenir animació.

### SpriteAnimationComponent (Animation)
`Explosion` a `lib/components/explosion.dart` usa `SpriteAnimationComponent`:
```dart
class Explosion extends SpriteAnimationComponent {
  animation = await game.loadSpriteAnimation(
    'explosion.png',
    SpriteAnimationData.sequenced(
      amount: 6,        // 6 fotogrames
      stepTime: 0.1,    // 0.1s per fotograma
      textureSize: Vector2(32, 32),
      loop: false,      // s'elimina en acabar
    ),
  );
}
```
El spritesheet `explosion.png` (192×32px) conté 6 fotogrames de 32×32px cadascun.

### AnimationGroup (SpriteAnimationGroupComponent)
El tutorial base no usa `SpriteAnimationGroupComponent` explícitament. En el nostre codi, els personatges (gorilles, plàtans) es renderitzen via Canvas API personalitzada. Per demostrar el concepte, l'animació del gorilla jugador canvia d'estat (idle/disparo) a través del `_bulletSpawner.timer.start/stop`, que és equivalent funcional a un AnimationGroup on el component canvia d'estat visual.

Per usar `SpriteAnimationGroupComponent` caldria un spritesheet amb múltiples estats (idle, running, shooting) per al gorilla.

---

## 4b5 - Generació d'elements

Sí, s'usa **generació d'elements** via `SpawnComponent`:

**Enemics** (`lib/game/space_shooter_game.dart:57`):
```dart
_enemySpawner = SpawnComponent(
  factory: (index) => Enemy(speedMultiplier: _enemySpeedMultiplier)
    ..position = Vector2(Random().nextDouble() * size.x, -Enemy.enemySize),
  period: _spawnPeriod,  // cada N segons (depèn del nivell)
  selfPositioning: true,
);
```

**Bales/plàtans** (`lib/components/player.dart:35`):
```dart
_bulletSpawner = SpawnComponent(
  factory: (index) => Bullet(
    position: absolutePosition - Vector2(0, height / 2),
  ),
  period: 0.25,          // cada 0.25s mentre es dispara
  selfPositioning: true,
  autoStart: false,      // s'activa/desactiva amb el tap
);
```

`SpawnComponent` crida la `factory` cada vegada que expira el `period`, creant nous components automàticament.

---

## 4b6 - Shape, Circle, Arithmetic

### Shape
Flame usa `Shape` com a base per a les àrees de detecció de col·lisions. Les hitboxes del joc:
- `RectangleHitbox()` a `Enemy.onLoad()` → hitbox activa rectangular
- `RectangleHitbox(collisionType: CollisionType.passive)` a `Bullet.onLoad()` → hitbox passiva

### Circle
No s'usa `CircleHitbox` explícitament, però el gorilla es dibuixa amb **cercles** via la Canvas API:
```dart
canvas.drawCircle(Offset(cx, cy - 15), 22, headPaint);  // cap del gorilla
canvas.drawCircle(Offset(cx - 8, cy - 20), 6, eyeWhite); // ull
```

### Arithmetic
S'usa àmpliament aritmètica vectorial i escalar:
```dart
// Vector2 arithmetic
position += delta;                          // suma de vectors
position.y -= _speed * dt;                 // multiplicació escalar
Vector2(size.x / 2, size.y * 0.8)         // divisió/multiplicació
absolutePosition - Vector2(0, height / 2)  // resta de vectors

// Clamping (aritmètica de límits)
position.x.clamp(width / 2, game.size.x - width / 2)

// Random arithmetic per spawn
Random().nextDouble() * size.x
```

---

## 4b7 - Comanda per desplegar a GitHub Pages

```bash
# 1. Compilar per a web
flutter build web --base-href "/a7-489-ra4-ra5-videojocs-ramonsamuel/"

# 2. Afegir els fitxers compilats a git
git add build/web
git commit -m "Deploy: build web per GitHub Pages"

# 3. Publicar la branca gh-pages
git subtree push --prefix build/web origin gh-pages
```

O amb `gh-pages` npm tool:
```bash
npm install -g gh-pages
gh-pages -d build/web
```

La URL resultant seria:
`https://ramonmascaro.github.io/a7-489-ra4-ra5-videojocs-ramonsamuel/`

---

## 4b8 - loadingBuilder, backgroundBuilder, OverlayBuilderMap

Els tres es troben a `lib/main.dart` dins el `GameWidget`:

### loadingBuilder
```dart
loadingBuilder: (context) => const Scaffold(
  backgroundColor: Color(0xFF0A1A0A),
  body: Center(
    child: Column(children: [
      CircularProgressIndicator(color: Colors.greenAccent),
      Text('Carregant Gorilles i Plàtans...'),
    ]),
  ),
),
```
Es mostra mentre `onLoad()` carrega els assets (sprites, parallax).

### backgroundBuilder
```dart
backgroundBuilder: (context) => Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF061206), Color(0xFF020802)],
    ),
  ),
),
```
Widget Flutter que es dibuixa **sota** el canvas del joc. Proporciona el fons verd fosc de jungla.

### overlayBuilderMap
```dart
overlayBuilderMap: {
  'MainMenu':      (context, game) => MainMenuOverlay(game: game),
  'LevelSelector': (context, game) => LevelSelectorOverlay(game: game),
  'Settings':      (context, game) => SettingsOverlay(game: game),
  'PauseMenu':     (context, game) => PauseMenuOverlay(game: game),
  'GameOver':      (context, game) => GameOverOverlay(game: game),
  'HUD':           (context, game) => HudOverlay(game: game),
},
```
Mapa de widgets Flutter que es poden mostrar sobre el joc cridant `game.overlays.add('NomOverlay')` i `game.overlays.remove('NomOverlay')`.

---

## 4b9 - Gorilles i Plàtans

Els personatges originals (naus espacials) han estat substituïts per:

- **Jugador** → Gorilla marró (`lib/components/player.dart`) — dibuixat amb Canvas API: cos ovalat, cap circular, ulls blancs, nas, celles expressives, boca somrient
- **Projectil** → Plàtan groc (`lib/components/bullet.dart`) — forma corbada amb reflexe lluminós
- **Enemic** → Gorilla enemic vermell (`lib/components/enemy.dart`) — similar al jugador però amb ulls vermells i celles enfadades

Tots renderitzats via Flutter's `Canvas` API (`canvas.drawCircle`, `canvas.drawRRect`, `canvas.drawPath`).

---

## 4b10 - Color de fons

El color de fons s'ha canviat de negre espacial a **verd fosc de jungla**:

**Via `backgroundColor()`** (`lib/game/space_shooter_game.dart`):
```dart
@override
Color backgroundColor() => const Color(0xFF0A1A0A); // verd jungla fosc
```

**Via `backgroundBuilder`** (`lib/main.dart`):
```dart
gradient: LinearGradient(
  colors: [Color(0xFF061206), Color(0xFF020802)],
)
```

---

## 4b11 - Pausa del joc

La pausa s'implementa a `lib/game/space_shooter_game.dart`:
```dart
void togglePause() {
  if (paused) {
    resumeEngine();           // reprèn el GameLoop
    overlays.remove('PauseMenu');
  } else {
    pauseEngine();            // atura el GameLoop
    overlays.add('PauseMenu');
  }
}
```

- `pauseEngine()` — atura el GameLoop (update/render s'aturen)
- `resumeEngine()` — reprèn el GameLoop
- El botó de pausa es troba al HUD (`lib/overlays/hud_overlay.dart`) — icona ⏸ a la cantonada superior dreta
- El menú de pausa (`lib/overlays/pause_menu_overlay.dart`) permet continuar, anar a configuració o tornar al menú

---

## 4b12 - Pantalla d'inici, Selector de nivell, Configuració

### Pantalla d'inici (`lib/overlays/main_menu_overlay.dart`)
- Títol "GORILLES & PLÀTANS" amb emoji 🦍
- Botó "JUGAR" → navega al selector de nivell
- Botó "CONFIGURACIÓ" → navega a la configuració

### Selector de nivell (`lib/overlays/level_selector_overlay.dart`)
- Tres nivells amb dificultat progressiva:
  - Nivell 1: 1 enemic/segon, velocitat normal
  - Nivell 2: 1.4 enemics/segon, velocitat ×1.5
  - Nivell 3: 2 enemics/segon, velocitat ×2
- Cada nivell inicia la partida via `game.startGame(level)`

### Configuració (`lib/overlays/settings_overlay.dart`)
- Toggle de so (activat/desactivat)
- Selector de dificultat (Fàcil / Normal / Difícil) via `SegmentedButton`
- Afecta la velocitat dels enemics i el ritme de spawn

---

## Estructura del projecte

```
lib/
├── main.dart                          # GameWidget + overlayBuilderMap
├── game/
│   └── space_shooter_game.dart        # FlameGame principal + GameLoop
├── components/
│   ├── player.dart                    # Gorilla jugador
│   ├── bullet.dart                    # Plàtan (projectil)
│   ├── enemy.dart                     # Gorilla enemic
│   └── explosion.dart                 # SpriteAnimationComponent
└── overlays/
    ├── main_menu_overlay.dart         # Pantalla d'inici
    ├── level_selector_overlay.dart    # Selector de nivell
    ├── settings_overlay.dart          # Configuració
    ├── pause_menu_overlay.dart        # Menú de pausa
    ├── hud_overlay.dart               # HUD (botó pausa)
    └── game_over_overlay.dart         # Pantalla de fi de joc

assets/images/
├── explosion.png   # 192×32px, 6 frames (SpriteAnimation)
├── stars_0.png     # Parallax capa 0
├── stars_1.png     # Parallax capa 1
├── stars_2.png     # Parallax capa 2
├── player.png      # Asset original (no usat - reemplaçat per Canvas)
├── bullet.png      # Asset original (no usat - reemplaçat per Canvas)
└── enemy.png       # Asset original (no usat - reemplaçat per Canvas)
```
