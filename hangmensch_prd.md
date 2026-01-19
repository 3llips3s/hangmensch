# Hangmensch - Product Requirements Document

## Project Overview

**Project Name:** Hangmensch  
**Description:** A German article learning game based on hangman mechanics  
**Platform:** Flutter (Web + Android + iOS)
**Primary Platform:** Web (GitHub Pages)
**Secondary:** Android (APK download), iOS (TestFlight/App Store - future)
**Target Audience:** German language learners  
**Core Mechanic:** Players must select the correct article (der/die/das) for German nouns before time runs out

---

## 1. Technical Stack

### Framework & Language
- **Flutter:** Latest stable version
- **Language:** Dart
- **Target Platforms:** 
  - Web (primary - GitHub Pages)
  - Android (APK download)
  - iOS (TestFlight/App Store - future deployment)

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  shared_preferences: ^2.2.3
  csv: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### Fonts
- **Playful text (nouns, articles, UI):** Quicksand (Regular, SemiBold, Bold)
- **Formal numbers (scores, timer):** JetBrains Mono (Regular)

---

## 2. Architecture

### Project Structure
```
hangmensch/
├── lib/
│   ├── main.dart
│   ├── features/
│   │   └── game/
│   │       ├── models/
│   │       │   ├── german_noun.dart
│   │       │   └── game_state.dart
│   │       ├── providers/
│   │       │   ├── nouns_provider.dart
│   │       │   ├── game_provider.dart
│   │       │   └── high_score_provider.dart
│   │       ├── widgets/
│   │       │   ├── gallows_painter.dart
│   │       │   ├── hangmensch_painter.dart
│   │       │   ├── article_button.dart
│   │       │   ├── circular_timer.dart
│   │       │   ├── noun_display.dart
│   │       │   ├── top_bar.dart
│   │       │   └── game_over_dialog.dart
│   │       └── game_screen.dart
│   └── core/
│       ├── constants/
│       │   ├── ui_colors.dart
│       │   ├── animation_durations.dart
│       │   ├── layout_constants.dart
│       │   └── ui_elements.dart
│       ├── theme/
│       │   └── app_theme.dart
│       └── utils/
│           ├── web_fullscreen.dart
│           └── csv_parser.dart
├── assets/
│   └── data/
│       └── german_nouns.csv
├── web/
│   ├── index.html
│   ├── favicon.png
│   └── manifest.json
└── pubspec.yaml
```

### Architecture Pattern
- **Feature-based architecture** with separation of concerns (UI, Data, Logic)
- **State Management:** Riverpod (StateNotifierProvider for game state)
- **Data Layer:** Repository pattern for noun management
- **Persistence:** SharedPreferences for high score

---

## 3. Data Models

### GermanNoun Model
```dart
class GermanNoun {
  final String article;      // "der", "die", or "das"
  final String noun;         // "Tisch"
  final String plural;       // "Tische" (stored but not used in game)
  final String translation;  // "table"
  
  GermanNoun({
    required this.article,
    required this.noun,
    required this.plural,
    required this.translation,
  });
  
  // Factory for CSV parsing
  factory GermanNoun.fromCsv(List<String> row) {
    return GermanNoun(
      article: row[0].trim(),
      noun: row[1].trim(),
      plural: row[2].trim(),
      translation: row[3].trim(),
    );
  }
}
```

### CSV Format
```csv
article,noun,plural,translation
der,Tisch,Tische,table
die,Katze,Katzen,cat
das,Haus,Häuser,house
```
- First row contains headers
- ~3000 nouns total
- Located at `assets/data/german_nouns.csv`

### Enums
```dart
enum GameStatus {
  idle,           // Showing "Tap → Los!"
  countdown,      // 3-2-1 countdown after restart
  playing,        // Timer running, waiting for answer
  revealed,       // Article revealed, showing feedback (1s pause)
  gameOver,       // All lives lost, showing dialog
}

enum Difficulty {
  easy,           // 6s per noun
  medium,         // 4s per noun
  hard,           // 2s per noun
  infinite,       // 1s per noun
}

enum HangmenschPart {
  head,           // Mistake 1
  leftArm,        // Mistake 2
  rightArm,       // Mistake 3
  leftLeg,        // Mistake 4
  skirt,          // Mistake 5
  rightLeg,       // Mistake 6
  eyes,           // Mistake 7 (X X - dead)
}
```

### GameState Model
```dart
class GameState {
  final GameStatus status;
  final int score;
  final int lives;              // 7 to 0
  final Difficulty difficulty;
  final int correctAnswers;     // Tracks progression through difficulties
  final double timeRemaining;   // Current timer value
  final GermanNoun? currentNoun;
  final String? revealedArticle; // Shown after answer
  final bool wasCorrect;        // For coloring revealed article
  final List<GermanNoun> nounPool;    // Remaining words
  final List<GermanNoun> usedNouns;   // Already shown words
  
  // Computed properties
  double get maxTime {
    switch (difficulty) {
      case Difficulty.easy:
        return 6.0;
      case Difficulty.medium:
        return 4.0;
      case Difficulty.hard:
        return 2.0;
      case Difficulty.infinite:
        return 1.0;
    }
  }
  
  int get mistakeCount => 7 - lives;  // For hangmensch drawing (0-7)
}
```

---

## 4. Game Mechanics

### Core Game Loop
1. Player sees German noun + English translation
2. Timer counts down from difficulty-based limit
3. Player selects article (der/die/das)
4. Correct answer:
   - Score +1
   - Article slides in (yellow)
   - Next noun after 1s
5. Wrong answer or timeout:
   - Lives -1
   - Article slides in (red)
   - Hangmensch body part draws
   - Next noun after 1s
6. Game over at 0 lives

### Difficulty Progression
- **Start:** Easy (6 seconds per noun)
- **After 10 correct:** Medium (4 seconds per noun)
- **After 30 correct total:** Hard (2 seconds per noun)
- **After 60 correct total:** Infinite (1 seconds per noun)

**Visual feedback on difficulty increase:**
- Circular timer does a brief double-pulse (400ms)
- No text overlay (minimal design)

### Word Pool Management
- Game starts with all 3000 nouns shuffled
- Nouns are removed after being shown (no immediate repeats)
- After all 3000 shown, pool resets and reshuffles
- Used words list clears on reset

### Scoring
- **Simple:** +1 point per correct answer
- **High score:** Persisted locally (SharedPreferences)
- **Display:** Top bar shows current score and high score

### Lives System
- Start with 7 lives (represented by hearts ❤️)
- Each mistake = -1 life + 1 hangmensch body part
- Game over at 0 lives

---

## 5. UI Specifications

### Color Palette (German Flag Theme)
```dart
class UIColors {
  // German flag colors
  static const background = Color(0xFF000000);        // Black
  static const gallowsColor = Color(0xFFFFCE00);      // German gold
  static const hangmenschColor = Color(0xFFDD0000);   // German red
  static const correctColor = Color(0xFFFFCE00);      // Yellow
  static const incorrectColor = Color(0xFFDD0000);    // Red
  static const textPrimary = Color(0xFFFFFFFF);       // White
  static const textSecondary = Color(0xFF888888);     // Gray (translation)
  static const buttonOutline = Color(0xFFFFCE00);     // Yellow outline
  
  // Timer urgency colors
  static const timerNormal = Color(0xFFFFCE00);       // Yellow
  static const timerWarning = Color(0xFFFF8C00);      // Orange (< 2s)
  static const timerCritical = Color(0xFFDD0000);     // Red (< 1s)
}
```

### Typography
```dart
class AppTypography {
  // Playful font (Quicksand)
  static const nounFontFamily = 'Quicksand';
  static const nounFontSize = 48.0;
  static const nounFontWeight = FontWeight.w600;
  
  static const translationFontSize = 20.0;
  static const translationOpacity = 0.6;
  
  static const buttonFontFamily = 'Quicksand';
  static const buttonFontSize = 28.0;
  static const buttonFontWeight = FontWeight.w700;
  
  // Formal font (JetBrains Mono)
  static const numberFontFamily = 'JetBrainsMono';
  static const scoreFontSize = 24.0;
  static const timerFontSize = 32.0;
}
```

### Layout & Spacing
```dart
class LayoutConstants {
  // Screen
  static const screenPadding = EdgeInsets.all(16.0);
  static const maxContentWidth = 600.0;  // For web
  
  // Top bar
  static const topBarHeight = 60.0;
  static const topBarIconSize = 24.0;
  static const topBarSpacing = 8.0;
  
  // Gallows
  static const gallowsHeight = 280.0;
  static const gallowsWidth = 200.0;
  
  // Noun display area
  static const nounAreaHeight = 140.0;
  static const nounTranslationSpacing = 8.0;
  static const articleNounSpacing = 12.0;
  
  // Timer
  static const timerSize = 80.0;
  static const timerStrokeWidth = 6.0;
  
  // Article buttons
  static const buttonHeight = 64.0;
  static const buttonWidth = 100.0;
  static const buttonSpacing = 16.0;
  static const buttonBorderWidth = 3.0;
  static const buttonBorderRadius = 12.0;
}
```

### UI Elements (Icons Only)
```dart
class UIElements {
  // Top bar
  static const highScoreIcon = Icons.emoji_events;    // 🏆 Trophy
  static const currentScoreIcon = Icons.speed;        // 📊 Speedometer
  static const livesIcon = Icons.favorite;            // ❤️ Heart
  
  
  
  // Game over dialog
  static const gameOverEmoji = "🪦";                  // Tombstone
  static const restartIcon = Icons.refresh;           // Circular arrow
  static const newHighScoreIndicator = "✨";          // Sparkle
  
  // Web only
  static const fullscreenIcon = Icons.fullscreen;
  static const fullscreenExitIcon = Icons.fullscreen_exit;
  
  // Text (minimal usage)
  static const tapToStart = "Tap → Los!";
}
```

### Screen Layout
```
┌──────────────────────────────────────┐
│ 🏆 123    📊 45    ❤️ 7             │  ← Top bar
│                                      │
│                                      │
│             [Gallows]                │  ← Gallows (gold)
│                                      │     + Hangmensch (red)
│                                      │
│              ⏱️ 4                     │  ← Timer
│                                      │
│            Tisch                     │  ← Noun (white, large)
│            table                     │     Translation (gray, small)
│                                      │
│                                      │
│   [der]    [die]    [das]            │  ← Article buttons (yellow outline)
│                                      │
│ 🖥️                                   │  ← Fullscreen (web, bottom-left)
└──────────────────────────────────────┘
```

### Responsive Behavior
```dart
class ResponsiveLayout {
  // Center-constrain content on wide screens
  static double getContentWidth(double screenWidth) {
    return min(screenWidth, LayoutConstants.maxContentWidth);
  }
  
  // Scale factor for different screen sizes
  static double getScaleFactor(double screenWidth) {
    if (screenWidth < 480) return 0.9;      // Mobile
    if (screenWidth < 768) return 1.0;      // Large mobile
    if (screenWidth < 1024) return 1.1;     // Tablet
    return 1.2;                             // Desktop
  }
}
```

---

## 6. Animations & Timing

### Animation Durations
```dart
class AnimationDurations {
  // Noun/article transitions
  static const nounFadeIn = 400;            // ms
  static const nounFadeOut = 300;           // ms
  static const articleSlideIn = 500;        // ms (article from left)
  static const revealPause = 1000;          // ms (learning pause)
  static const countdownDigit = 300;        // ms (each 3, 2, 1)
  
  // Button feedback
  static const buttonPress = 200;           // ms
  static const wrongShake = 300;            // ms
  static const correctPulse = 300;          // ms
  static const correctButtonBounce = 500;   // ms
  
  // Gallows
  static const gallowsPartFade = 300;       // ms (each gallows part)
  static const gallowsPartDelay = 200;      // ms (between parts)
  static const hangmenschBodyPart = 400;    // ms (each body part trace)
  
  // Dialog
  static const dialogFadeIn = 300;          // ms
  static const dialogSlideUp = 400;         // ms
  
  // Timer
  static const timerTick = 100;             // ms (update frequency)
  
  // Difficulty change
  static const difficultyPulse = 400;       // ms (timer double-pulse)
  
  // Game over swing
  static const swingDuration = 1200;        // ms (pendulum cycle)
}
```

### Animation Curves
```dart
class AnimationCurves {
  static const nounFade = Curves.easeInOut;
  static const articleSlide = Curves.easeOutCubic;
  static const buttonFeedback = Curves.easeOut;
  static const wrongShake = Curves.elasticIn;
  static const correctPulse = Curves.easeInOut;
  static const gallowsDraw = Curves.easeInOut;
  static const dialogAppear = Curves.easeOutBack;
  static const swing = Curves.easeInOut;
}
```

### Key Animation Sequences

#### Sequence 1: Initial Gallows Fade-In (Idle State)
```
App loads (black screen)
  ↓
Base fades in (300ms)
  ↓ 200ms pause
Vertical pole fades in (300ms)
  ↓ 200ms pause
Horizontal bar fades in (300ms)
  ↓ 200ms pause
Rope fades in (300ms)
  ↓
"Tap → Los!" appears in noun area
```

#### Sequence 2: Game Start from Idle
```
User taps anywhere on screen
  ↓
"Tap → Los!" fades out (300ms)
  ↓
First noun + translation fade in (400ms)
  ↓
Timer starts counting down immediately
Article buttons become active
```

#### Sequence 3: Correct Answer
```
User taps correct article button
  ↓
Button pulses yellow (300ms)
  ↓
Correct article slides in from left next to noun (500ms, yellow color)
Noun + translation shift right to accommodate
  ↓
Hold visible for 1000ms (learning pause)
Buttons disabled during this time
  ↓
Entire block (article + noun + translation) fades out (300ms)
  ↓
Next noun + translation fade in (400ms)
  ↓
Timer resets to difficulty max and starts
Check if correctAnswers threshold met → increase difficulty if needed
```

#### Sequence 4: Wrong Answer
```
User taps wrong article button
  ↓
Wrong button shakes + red fill (300ms)
Correct button bounces + yellow highlight (500ms)
  ↓
Lives decrement
Hangmensch next body part traces in (400ms)
  ↓
Correct article slides in from left (500ms, red color)
Noun + translation shift right
  ↓
Hold visible for 1000ms
  ↓
Fade out and continue as correct answer sequence
```

#### Sequence 5: Timer Expires (No Answer)
```
Timer hits 0
  ↓
All three buttons briefly pulse red (200ms)
  ↓
Correct article slides in (500ms, red color)
Lives decrement
Hangmensch body part traces in (400ms)
  ↓
Hold 1000ms, then continue
```

#### Sequence 6: Game Over
```
Lives reach 0 (7th mistake)
  ↓
Final hangmensch body part (X eyes) traces in (400ms)
  ↓
Brief pause (500ms)
  ↓
Hangmensch begins subtle swing animation (pendulum, continuous)
  ↓
Game over dialog fades + slides up from bottom (400ms)
Shows: 🪦, final score, high score (with ✨ if new), restart button
```

#### Sequence 7: Restart After Game Over
```
User taps restart button (🔄)
  ↓
Dialog fades out (300ms)
  ↓
Game resets: score = 0, lives = 7, difficulty = easy
Noun pool reloaded and shuffled
Hangmensch clears from gallows
  ↓
900ms countdown in noun area:
  - "3" pulses (scales 0.5→1.2→1.0) for 300ms
  - "2" pulses for 300ms
  - "1" pulses for 300ms
  ↓
First noun fades in, timer starts
```

#### Sequence 8: Difficulty Increase
```
Correct answer pushes correctAnswers to threshold (10, 30, or 60)
  ↓
After article reveal and before fade-out:
  - Circular timer does double-pulse (400ms)
  - No text, no other visual changes
  ↓
Next noun timer starts with new max time
```

### Timer Behavior
- Updates every 100ms for smooth circular progress
- Color changes:
  - Yellow (normal): > 2 seconds remaining
  - Orange (warning): ≤ 2 seconds remaining
  - Red (critical): ≤ 1 second remaining
- Pauses during:
  - Article reveal (1s)
  - Button feedback animations
  - Countdown (3-2-1)
  - Game over dialog
- Active during:
  - Normal play (waiting for user input)

---

## 7. CustomPaint Specifications

### Gallows Structure (Gold, Sequential Fade-In)

```dart
class GallowsDrawingSpecs {
  static const width = 200.0;
  static const height = 280.0;
  
  // Colors
  static const gallowsColor = UIColors.gallowsColor;      // Gold
  static const hangmenschColor = UIColors.hangmanColor;   // Red
  
  // Stroke widths
  static const gallowsStrokeWidth = 4.0;
  static const ropeStrokeWidth = 3.0;
  static const bodyStrokeWidth = 3.0;
  
  // === GALLOWS STRUCTURE (Asymmetric T) ===
  
  // Base (horizontal line at bottom, centered)
  static const baseStart = Offset(50, 260);
  static const baseEnd = Offset(150, 260);
  
  // Vertical pole (from base upward)
  static const poleStart = Offset(100, 260);
  static const poleEnd = Offset(100, 40);
  
  // Horizontal bar (asymmetric T: small left, long right)
  static const barStart = Offset(85, 40);       // 15px left of pole
  static const barEnd = Offset(170, 40);        // 70px right of pole
  
  // Rope (near right end, NOT flush - 10px before end)
  static const ropeStart = Offset(160, 40);
  static const ropeEnd = Offset(160, 75);
  
  // === HANGMENSCH BODY PARTS (Floating limbs, no torso) ===
  
  // Head (circle at rope end)
  static const headCenter = Offset(160, 95);
  static const headRadius = 18.0;
  
  // Left arm (from head area, angled down-left, floating)
  static const leftArmStart = Offset(160, 100);
  static const leftArmEnd = Offset(145, 120);
  
  // Right arm (from head area, angled down-right, floating)
  static const rightArmStart = Offset(160, 100);
  static const rightArmEnd = Offset(175, 120);
  
  // Left leg (straight down from head area, floating)
  static const leftLegStart = Offset(155, 130);
  static const leftLegEnd = Offset(150, 170);
  
  // Skirt (triangle: hip out, then back in - female representation)
  static const skirtHipCenter = Offset(165, 130);
  static const skirtOutRight = Offset(180, 150);    // OUT to right
  static const skirtHemRight = Offset(172, 165);    // BACK IN (hem right)
  static const skirtHemLeft = Offset(158, 165);     // Hem left side
  static const skirtOutLeft = Offset(150, 150);     // Back to left hip
  
  // Right leg (drops from skirt hem)
  static const rightLegStart = Offset(165, 165);
  static const rightLegEnd = Offset(165, 205);
  
  // X X Eyes (final stage - dead)
  static const leftEyeX1 = Offset(153, 92);
  static const leftEyeX2 = Offset(159, 98);
  static const leftEyeX3 = Offset(159, 92);
  static const leftEyeX4 = Offset(153, 98);
  
  static const rightEyeX1 = Offset(161, 92);
  static const rightEyeX2 = Offset(167, 98);
  static const rightEyeX3 = Offset(167, 92);
  static const rightEyeX4 = Offset(161, 98);
}
```

### Gallows Drawing Methods
```dart
// Gallows painter (always visible after initial fade-in)
class GallowsPainter extends CustomPainter {
  final double opacity;  // For fade-in animation
  
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GallowsDrawingSpecs.gallowsColor.withOpacity(opacity)
      ..strokeWidth = GallowsDrawingSpecs.gallowsStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Draw all parts
    _drawBase(canvas, paint);
    _drawVerticalPole(canvas, paint);
    _drawHorizontalBar(canvas, paint);
    _drawRope(canvas, paint);
  }
  
  void _drawBase(Canvas canvas, Paint paint) {
    canvas.drawLine(GallowsDrawingSpecs.baseStart, 
                   GallowsDrawingSpecs.baseEnd, paint);
  }
  
  void _drawVerticalPole(Canvas canvas, Paint paint) {
    canvas.drawLine(GallowsDrawingSpecs.poleStart, 
                   GallowsDrawingSpecs.poleEnd, paint);
  }
  
  void _drawHorizontalBar(Canvas canvas, Paint paint) {
    canvas.drawLine(GallowsDrawingSpecs.barStart, 
                   GallowsDrawingSpecs.barEnd, paint);
  }
  
  void _drawRope(Canvas canvas, Paint paint) {
    final ropePaint = paint..strokeWidth = GallowsDrawingSpecs.ropeStrokeWidth;
    canvas.drawLine(GallowsDrawingSpecs.ropeStart, 
                   GallowsDrawingSpecs.ropeEnd, ropePaint);
  }
}
```

### Hangmensch Drawing Methods
```dart
// Hangmensch painter (traces in body parts based on mistakes)
class HangmenschPainter extends CustomPainter {
  final int mistakeCount;        // 0-7
  final bool isGameOver;
  final Animation<double>? swingAnimation;  // For game over pendulum
  
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GallowsDrawingSpecs.hangmenschColor
      ..strokeWidth = GallowsDrawingSpecs.bodyStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    if (mistakeCount >= 1) _drawHead(canvas, paint);
    if (mistakeCount >= 2) _drawLeftArm(canvas, paint);
    if (mistakeCount >= 3) _drawRightArm(canvas, paint);
    if (mistakeCount >= 4) _drawLeftLeg(canvas, paint);
    if (mistakeCount >= 5) _drawSkirt(canvas, paint);
    if (mistakeCount >= 6) _drawRightLeg(canvas, paint);
    if (mistakeCount >= 7) _drawEyes(canvas, paint);
  }
  
  void _drawHead(Canvas canvas, Paint paint) {
    // Apply swing offset if game over
    final center = isGameOver && swingAnimation != null
        ? GallowsDrawingSpecs.headCenter.translate(
            swingAnimation!.value * SwingParams.horizontalAmplitude,
            sin(swingAnimation!.value * pi) * SwingParams.verticalBob
          )
        : GallowsDrawingSpecs.headCenter;
    
    canvas.drawCircle(center, GallowsDrawingSpecs.headRadius, paint);
  }
  
  void _drawLeftArm(Canvas canvas, Paint paint) {
    // Apply swing offset if game over (with slight lag)
    canvas.drawLine(
      GallowsDrawingSpecs.leftArmStart,
      GallowsDrawingSpecs.leftArmEnd,
      paint
    );
  }
  
  void _drawRightArm(Canvas canvas, Paint paint) {
    canvas.drawLine(
      GallowsDrawingSpecs.rightArmStart,
      GallowsDrawingSpecs.rightArmEnd,
      paint
    );
  }
  
  void _drawLeftLeg(Canvas canvas, Paint paint) {
    canvas.drawLine(
      GallowsDrawingSpecs.leftLegStart,
      GallowsDrawingSpecs.leftLegEnd,
      paint
    );
  }
  
  void _drawSkirt(Canvas canvas, Paint paint) {
    // Triangle path: hip → out → back in → close
    final path = Path()
      ..moveTo(GallowsDrawingSpecs.skirtHipCenter.dx, 
               GallowsDrawingSpecs.skirtHipCenter.dy)
      ..lineTo(GallowsDrawingSpecs.skirtOutRight.dx, 
               GallowsDrawingSpecs.skirtOutRight.dy)
      ..lineTo(GallowsDrawingSpecs.skirtHemRight.dx, 
               GallowsDrawingSpecs.skirtHemRight.dy)
      ..lineTo(GallowsDrawingSpecs.skirtHemLeft.dx, 
               GallowsDrawingSpecs.skirtHemLeft.dy)
      ..lineTo(GallowsDrawingSpecs.skirtOutLeft.dx, 
               GallowsDrawingSpecs.skirtOutLeft.dy)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  void _drawRightLeg(Canvas canvas, Paint paint) {
    canvas.drawLine(
      GallowsDrawingSpecs.rightLegStart,
      GallowsDrawingSpecs.rightLegEnd,
      paint
    );
  }
  
  void _drawEyes(Canvas canvas, Paint paint) {
    final eyePaint = paint..strokeWidth = 2.5;
    
    // Left X
    canvas.drawLine(GallowsDrawingSpecs.leftEyeX1, 
                   GallowsDrawingSpecs.leftEyeX2, eyePaint);
    canvas.drawLine(GallowsDrawingSpecs.leftEyeX3, 
                   GallowsDrawingSpecs.leftEyeX4, eyePaint);
    
    // Right X
    canvas.drawLine(GallowsDrawingSpecs.rightEyeX1, 
                   GallowsDrawingSpecs.rightEyeX2, eyePaint);
    canvas.drawLine(GallowsDrawingSpecs.rightEyeX3, 
                   GallowsDrawingSpecs.rightEyeX4, eyePaint);
  }
  
  @override
  bool shouldRepaint(HangmenschPainter oldDelegate) {
    return oldDelegate.mistakeCount != mistakeCount ||
           oldDelegate.isGameOver != isGameOver;
  }
}
```

### Swing Animation Parameters (Game Over)
```dart
class SwingParams {
  static const horizontalAmplitude = 8.0;    // 8px side-to-side
  static const verticalBob = 2.0;            // 2px up-down
  static const duration = 1200;              // ms per swing cycle
  static const curve = Curves.easeInOut;
}
```

---

## 8. Implementation Phases

### Phase 1: Project Setup & Data Layer
**Deliverables:**
- Flutter project created with correct structure
- Dependencies added to pubspec.yaml
- Font files added and configured
- GermanNoun model implemented
- CSV parser utility created
- Nouns provider (Riverpod FutureProvider) for loading CSV
- CSV file with 3000 nouns in assets

**Test Criteria:**
- App runs without errors
- CSV loads successfully
- Can print first 10 nouns to console
- Nouns have correct article, noun, translation fields

---

### Phase 2: Core Game Logic
**Deliverables:**
- GameState model with all fields and computed properties
- Game provider (Riverpod StateNotifierProvider)
- High score provider with SharedPreferences
- Difficulty progression logic (10→30→60 thresholds)
- Word pool management (shuffle, remove used, reset)
- Game state transitions (idle→countdown→playing→revealed→gameOver)
- Timer logic with pause/resume

**Test Criteria:**
- Can initialize game state
- Can select article and update state correctly
- Lives decrement on wrong answer
- Score increments on correct answer
- Difficulty changes at correct thresholds
- High score persists across app restarts
- Word pool doesn't repeat until exhausted

---

### Phase 3: UI Foundation
**Deliverables:**
- GameScreen scaffold with black background
- Top bar with score displays (🏆 high score, 📊 current score, ❤️ lives)
- Article buttons (der, die, das) at bottom
- Dialog box consistent with app theme
- Responsive layout (max 600px width on web)
- App theme with colors and typography
- SafeArea and proper padding

**Test Criteria:**
- Layout looks correct on mobile size
- Layout looks correct on desktop (centered, max 600px)
- Icons display correctly
- Numbers use JetBrains Mono font
- Buttons are tappable and show press feedback

---

### Phase 4: Custom Painters
**Deliverables:**
- GallowsPainter with all 4 parts (base, pole, bar, rope)
- Sequential fade-in animation for gallows (idle state)
- HangmenschPainter with 7 body parts
- Body part trace-in animation (400ms per part)
- Swing animation for game over state
- Proper positioning and proportions

**Test Criteria:**
- Gallows fades in sequentially on app start
- Each hangmensch part draws at correct mistake count
- Floating limbs don't touch (minimal aesthetic)
- Skirt forms correct triangle shape
- Swing animation plays smoothly on game over
- All coordinates match specifications

---

### Phase 5: Game Flow & Animations
**Deliverables:**
- Circular timer widget with progress indicator
- Timer color changes (yellow→orange→red)
- Noun display with article reveal animation
- Article slides in from left (500ms)
- Noun + translation shift right when article appears
- Button feedback animations (pulse, shake, bounce)
- Countdown animation (3-2-1)
- Game over dialog with tombstone, scores, restart
- Difficulty increase pulse animation
- All animation sequences from Section 6

**Test Criteria:**
- Timer counts down smoothly
- Timer changes color at 2s and 1s
- Article slides in correctly (yellow if right, red if wrong)
- Buttons provide clear feedback
- Countdown works before game start
- Dialog appears on game over with correct scores
- Can restart game successfully
- Full game loop works end-to-end

---

### Phase 6: Polish & Web Support
**Deliverables:**
- Web fullscreen toggle button (bottom-left)
- Fullscreen functionality for web
- Immersive mode for mobile (Android)
- Keyboard shortcuts (R=der, E=die, S=das, Space=restart, F=fullscreen)
- Haptic feedback for mobile (light/medium/heavy)
- Edge case handling (CSV errors, tab focus, etc.)
- Portrait mode lock (mobile)
- Web meta tags and favicon

**Test Criteria:**
- Fullscreen works on web browsers
- Keyboard shortcuts respond correctly
- Haptics trigger on mobile
- App handles tab focus loss/gain properly
- Orientation locked to portrait on mobile
- No console errors or warnings
- Ready for deployment

---

## 9. Edge Cases & Error Handling

### CSV Loading
```dart
// Handle CSV load failures
try {
  final nouns = await loadNouns();
  if (nouns.isEmpty) {
    // Show error dialog: "Couldn't load word database"
    // Provide retry button
  }
} catch (e) {
  // Log error, show user-friendly message
}
```

### Timer Edge Cases
- Timer reaches exactly 0 → Treat as wrong answer
- Tab loses focus (web) → Pause timer
- Tab regains focus → Resume timer
- Timer during animations → Paused

### Button Interaction
- Disable buttons during:
  - Article reveal (slide in + learning pause)
  - Countdown (900ms)
  - Fade transitions
  - Game over state
- Use GameStatus enum to control

### Word Pool
- Exhaust all 3000 words → Reset pool, reshuffle, continue seamlessly
- Invalid CSV entries → Skip and log

### Long Nouns
- Nouns > container width → Use FittedBox or scale font down
- Ensure translation always visible

### High Score
- New high score on game over → Save immediately
- Show sparkle ✨ indicator in dialog

---

## 10. Web-Specific Requirements

### Fullscreen
```dart
// Web fullscreen (requires dart:html)
import 'dart:html' as html;

void toggleFullscreen() {
  if (!isFullscreen) {
    html.document.documentElement?.requestFullscreen();
  } else {
    html.document.exitFullscreen();
  }
}
```

### Keyboard Shortcuts
```dart
// Handle keyboard input
void handleKeyPress(KeyEvent event) {
  if (state.status != GameStatus.playing) return;
  
  switch (event.logicalKey.keyLabel.toUpperCase()) {
    case 'R':
      selectArticle('der');
      break;
    case 'E':
      selectArticle('die');
      break;
    case 'S':
      selectArticle('das');
      break;
    case 'F':
      toggleFullscreen();
      break;
    case ' ':
      if (state.status == GameStatus.gameOver) restart();
      break;
  }
}
```

### Meta Tags (index.html)
```html
<meta name="description" content="Hangmensch - Learn German articles through a fun hangman-style game">
<meta property="og:title" content="Hangmensch - German Article Learning Game">
<meta property="og:description" content="Master der, die, das with this fast-paced learning game">
```

---

## 11. Accessibility

### Semantic Labels (English for screen readers)
```dart
Semantics(
  label: 'High score',
  child: IconWithNumber(icon: Icons.emoji_events, number: highScore),
)

Semantics(
  label: 'Masculine article: der',
  button: true,
  child: ArticleButton('der'),
)
```

### Minimum Touch Targets
- All interactive elements: 44x44 minimum (accessibility guideline)

### Color Contrast
- Yellow on black: ✓ High contrast
- Red on black: ✓ High contrast
- Ensure timer color changes are supplemented by visual size/position cues

---

## 12. Success Criteria

### Game is Complete When:
- [ ] All 6 implementation phases done
- [ ] Full game loop functional (start → play → game over → restart)
- [ ] All animations smooth and match specifications
- [ ] Gallows and hangmensch draw correctly
- [ ] Difficulty progression works
- [ ] High score persists
- [ ] Works on web (Chrome, Firefox, Safari)
- [ ] Works on Android mobile
- [ ] Works on iOS mobile (future - not required for v1)
- [ ] No console errors or warnings
- [ ] Responsive on different screen sizes
- [ ] Keyboard shortcuts functional (web)
- [ ] Fullscreen works (web)
- [ ] Deployed to GitHub Pages
- [ ] APK available for download

---

## Appendix A: Code Patterns

### Riverpod Provider Pattern
```dart
// FutureProvider for async data loading
final nounsProvider = FutureProvider<List<GermanNoun>>((ref) async {
  return await CsvParser.loadNouns('assets/data/german_nouns.csv');
});

// StateNotifierProvider for game state
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final nouns = ref.watch(nounsProvider).value ?? [];
  return GameNotifier(nouns);
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(List<GermanNoun> nouns) : super(GameState.initial(nouns));
  
  void selectArticle(String article) {
    // Update state immutably
    state = state.copyWith(/* changes */);
  }
}
```

### Widget Structure Pattern
```dart
class GameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    
    return Scaffold(
      backgroundColor: UIColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Stack(
              children: [
                Column(/* main game layout */),
                if (gameState.status == GameStatus.gameOver)
                  GameOverDialog(),
                if (kIsWeb)
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: FullscreenButton(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Appendix B: Testing Checklist

### Unit Tests
- [ ] GermanNoun.fromCsv() parses correctly
- [ ] GameState.mistakeCount computed property
- [ ] GameState.maxTime returns correct values
- [ ] Difficulty progression logic

### Widget Tests
- [ ] Article buttons trigger state change
- [ ] Timer updates correctly
- [ ] Score displays update

### Integration Tests
- [ ] Complete game flow (start → multiple turns → game over → restart)
- [ ] High score persistence
- [ ] Word pool management

### Manual Testing
- [ ] Web fullscreen on Chrome, Firefox, Safari
- [ ] Mobile immersive mode (Android)
- [ ] Keyboard shortcuts (web)
- [ ] Responsive layout on phone, tablet, desktop
- [ ] Long noun handling
- [ ] All animations smooth (60fps)
- [ ] No visual glitches or jank

---

## Notes for Implementation

### Order of Implementation
Follow phases 1-6 in sequence. Each phase builds on the previous.

### When to Use Riverpod
- `FutureProvider`: CSV loading (async, one-time)
- `StateNotifierProvider`: Game state (mutable, reactive)
- `Provider`: Constants, read-only data

### When to Use CustomPaint
- Gallows: CustomPaint (simple lines)
- Hangmensch: CustomPaint (lines, circles, paths)
- Timer: CustomPaint (circular progress indicator)

### Animation Best Practices
- Use `AnimationController` with `vsync` (SingleTickerProviderStateMixin)
- Dispose controllers in widget dispose()
- Use `CurvedAnimation` for easing
- Keep animations under 500ms for responsiveness

### State Management Tips
- Keep GameState immutable
- Use `copyWith()` for updates
- Computed properties for derived values
- No business logic in widgets

---

**END OF PRD**
