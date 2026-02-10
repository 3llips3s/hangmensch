# Hangmensch - Implementation Progress

## Overview
This file tracks implementation progress across 6 phases. Update checkboxes after testing and verifying each completed task.

---

## Phase 1: Project Setup & Data Layer
**Goal:** Set up project structure, dependencies, and CSV data loading

- [x] Create Flutter project with correct folder structure
- [x] Add dependencies to pubspec.yaml (riverpod, shared_preferences, csv)
- [x] Add font files (Quicksand, JetBrains Mono) and configure in pubspec.yaml
- [x] Create GermanNoun model (`lib/features/game/models/german_noun.dart`)
- [x] Implement CSV parser utility (`lib/core/utils/csv_parser.dart`)
- [x] Create nouns provider (`lib/features/game/providers/nouns_provider.dart`)
- [x] Add CSV file with 3000 nouns to `assets/data/german_nouns.csv`
- [x] Verify CSV loads successfully

**Status:** Completed  
**Blockers:** None  
**Notes:** 

**Test Checklist:**
- [ ] Run `flutter pub get` without errors
- [ ] App runs and displays debug console
- [ ] CSV loads successfully (check console for "Loaded X nouns")
- [ ] Can print first 10 nouns with correct fields

**Git Commit (after completion):**
```bash
git add .
git commit -m "feat: implement Phase 1 - data models and CSV parsing

- Add GermanNoun model with article, noun, plural, translation
- Implement CSV parser for german_nouns.csv
- Set up Riverpod provider for nouns loading
- Add dependencies: riverpod, csv, shared_preferences
- Configure fonts: Quicksand and JetBrains Mono"
```

---

## Phase 2: Core Game Logic
**Goal:** Implement game state management and business logic

- [x] Create GameState model (`lib/features/game/models/game_state.dart`)
- [x] Add GameStatus enum (idle, countdown, playing, revealed, gameOver)
- [x] Add Difficulty enum (easy, medium, hard, infinite)
- [x] Add HangmenschPart enum (head, leftArm, rightArm, leftLeg, skirt, rightLeg, eyes)
- [x] Implement computed properties (maxTime, mistakeCount)
- [x] Create game provider (`lib/features/game/providers/game_provider.dart`)
- [x] Implement game state transitions
- [x] Implement difficulty progression logic (10→30→60 thresholds)
- [x] Implement word pool management (shuffle, remove used, reset after 3000)
- [x] Create high score provider (`lib/features/game/providers/high_score_provider.dart`)
- [x] Implement SharedPreferences for high score persistence
- [x] Implement timer logic with pause/resume
- [x] Implement article selection logic (correct/wrong/timeout)

**Status:** Completed  
**Blockers:** Phase 1 must be complete  
**Notes:**

**Test Checklist:**
- [ ] Can initialize game state with correct defaults
- [ ] Can select article and state updates correctly
- [ ] Lives decrement on wrong answer
- [ ] Score increments on correct answer
- [ ] Difficulty increases at 10, 30, 60 correct answers
- [ ] High score persists after app restart
- [ ] Word pool doesn't repeat nouns until all 3000 shown
- [ ] Timer decrements correctly
- [ ] Timer pauses/resumes as expected

**Git Commit (after completion):**
```bash
git add .
git commit -m "feat: implement Phase 2 - game logic and state management

- Add GameState model with all fields and enums
- Implement game provider with Riverpod StateNotifier
- Add difficulty progression (10/30/60 thresholds)
- Implement word pool management with shuffle/reset
- Add high score persistence with SharedPreferences
- Implement timer logic with pause/resume
- Add article selection with correct/wrong/timeout handling"
```

---

## Phase 3: UI Foundation
**Goal:** Build basic UI layout and structure

- [x] Create GameScreen scaffold (`lib/features/game/game_screen.dart`)
- [x] Set background to black
- [x] Implement SafeArea and responsive layout (max 600px width)
- [x] Create app theme (`lib/core/theme/app_theme.dart`)
- [x] Define UI colors (`lib/core/constants/ui_colors.dart`)
- [x] Define layout constants (`lib/core/constants/layout_constants.dart`)
- [x] Define UI elements (`lib/core/constants/ui_elements.dart`)
- [x] Create TopBar widget (`lib/features/game/widgets/top_bar.dart`)
- [x] Add high score display (🏆 + number)
- [x] Add current score display (📊 + number)
- [x] Add lives display (❤️ + number)
- [x] Create ArticleButton widget (`lib/features/game/widgets/article_button.dart`)
- [x] Add three buttons at bottom (der, die, das)
- [x] Implement button press feedback
- [ ] Test responsive layout on different screen sizes

**Status:** Completed  
**Blockers:** Phase 2 must be complete  
**Notes:**

**Test Checklist:**
- [ ] Layout looks correct on mobile (375px width)
- [ ] Layout looks correct on tablet (768px width)
- [ ] Layout looks correct on desktop (centered, max 600px)
- [ ] Icons display correctly in top bar
- [ ] Numbers use JetBrains Mono font
- [ ] Noun text uses Quicksand font
- [ ] Buttons are tappable with visual feedback
- [ ] Colors match German flag theme (gold/red/black)

**Git Commit (after completion):**
```bash
git add .
git commit -m "feat: implement Phase 3 - UI foundation and layout

- Create GameScreen with black background and responsive layout
- Add TopBar with score displays (trophy, speedometer, heart icons)
- Create ArticleButton widget with yellow outline
- Implement app theme with German flag colors
- Add constants for colors, layout, and UI elements
- Center-constrain content to 600px max width for web
- Configure typography (Quicksand for text, JetBrains Mono for numbers)"
```

---

## Phase 4: Custom Painters
**Goal:** Implement gallows and hangmensch with CustomPaint

- [x] Create constants file (`lib/core/constants/gallows_specs.dart`)
- [x] Define all gallows coordinates (base, pole, bar, rope)
- [x] Define all hangmensch coordinates (head, arms, legs, skirt, eyes)
- [x] Create GallowsPainter (`lib/features/game/widgets/gallows_painter.dart`)
- [x] Implement base drawing method
- [x] Implement vertical pole drawing method
- [x] Implement horizontal bar drawing method (asymmetric T)
- [x] Implement rope drawing method
- [x] Add sequential fade-in animation for gallows (idle state)
- [x] Create HangmenschPainter (`lib/features/game/widgets/hangmensch_painter.dart`)
- [x] Implement head drawing (circle)
- [x] Implement left arm drawing (floating)
- [x] Implement right arm drawing (floating)
- [x] Implement left leg drawing (straight)
- [x] Implement skirt drawing (triangle path)
- [x] Implement right leg drawing (from skirt)
- [x] Implement eyes drawing (X X)
- [x] Add trace-in animation for body parts (400ms each)
- [x] Implement swing animation for game over
- [x] Test all body parts appear at correct mistake count

**Status:** Completed  
**Blockers:** Phase 3 must be complete  
**Notes:**

**Test Checklist:**
- [ ] Gallows fades in sequentially during idle state
- [ ] Gallows forms asymmetric T (small left, long right)
- [ ] Rope hangs near right end (not flush)
- [ ] Head appears on 1st mistake
- [ ] Left arm appears on 2nd mistake
- [ ] Right arm appears on 3rd mistake
- [ ] Left leg appears on 4th mistake
- [ ] Skirt appears on 5th mistake (triangle shape correct)
- [ ] Right leg appears on 6th mistake
- [ ] Eyes (X X) appear on 7th mistake
- [ ] Floating limbs don't touch (minimal aesthetic)
- [ ] Swing animation plays on game over (subtle pendulum)
- [ ] All proportions and coordinates match specifications

**Git Commit (after completion):**
```bash
git add .
git commit -m "feat: implement Phase 4 - custom painters for gallows and hangmensch

- Create GallowsPainter with asymmetric T structure
- Add sequential fade-in animation for gallows parts
- Create HangmenschPainter with 7 body parts
- Implement floating limbs design (no torso)
- Add skirt representation (triangle path)
- Implement trace-in animation for body parts
- Add swing animation for game over state
- Define all coordinates in gallows_specs constants"
```

---

## Phase 5: Game Flow & Animations
**Goal:** Implement full game flow with all animations

- [x] Create animation durations constants (`lib/core/constants/animation_durations.dart`)
- [x] Create CircularTimer widget (`lib/features/game/widgets/circular_timer.dart`)
- [x] Implement circular progress indicator
- [x] Implement timer color changes (yellow→orange→red)
- [x] Add timer number in center
- [x] Integrate timer with game state
- [x] Create NounDisplay widget (`lib/features/game/widgets/noun_display.dart`)
- [x] Implement "Tap → Los!" for idle state
- [x] Implement countdown animation (3-2-1, 300ms each)
- [x] Implement noun fade-in (400ms)
- [x] Implement article slide-in from left (500ms)
- [x] Implement noun + translation shift right when article appears
- [x] Implement 1s learning pause after reveal
- [x] Implement fade-out transition to next noun
- [x] Add button feedback animations
- [x] Implement correct button pulse (yellow, 300ms)
- [x] Implement wrong button shake (red, 300ms)
- [x] Implement correct button bounce on wrong answer (500ms)
- [x] Implement timeout feedback (all buttons pulse red)
- [x] Create GameOverDialog (`lib/features/game/widgets/game_over_dialog.dart`)
- [x] Add tombstone emoji 🪦
- [x] Display final score (📊)
- [x] Display high score (🏆 with ✨ if new)
- [x] Add restart button (🔄 icon only)
- [x] Implement dialog fade + slide animation
- [x] Implement difficulty increase pulse (timer double-pulse, 400ms)
- [x] Wire up all animations to game state transitions
- [x] Test full game loop end-to-end

**Status:** Completed  
**Blockers:** Phase 4 must be complete  
**Notes:**

**Test Checklist:**
- [x] Idle state shows "Tap → Los!" and gallows fade-in
- [x] Tapping starts countdown (3-2-1)
- [x] First noun appears after countdown
- [x] Timer counts down smoothly
- [x] Timer changes color at 2s (orange) and 1s (red)
- [x] Correct answer: button pulses yellow, article slides in yellow
- [x] Wrong answer: button shakes red, correct button bounces, article slides in red
- [x] Timeout: all buttons pulse red, article slides in red
- [x] Article + noun held for 1s before next noun
- [x] Noun + translation shift right when article appears
- [x] Difficulty increases at 10, 30, 60 (timer pulses)
- [x] Game over shows dialog with tombstone, scores, restart
- [x] New high score shows sparkle ✨
- [x] Restart triggers countdown and new game
- [x] All animations smooth (no jank)
- [x] Buttons disabled during animations
- [x] Play 5-10 full games to ensure stability

**Git Commit (after completion):**
```bash
git add .
git commit -m "feat: implement Phase 5 - game flow and animations

- Create CircularTimer with color changes (yellow/orange/red)
- Add NounDisplay with 3-2-1 countdown for restarts
- Implement interactive button feedback (pulse, shake, red fill)
- Create minimal dark-themed GameOverDialog with gold accents
- Implement difficulty increase pulse animation
- Wire all flow logic (correct/wrong/timeout/restart)
- Handle high score sparkle ✨ and score icons"
```

---

## Phase 6: Polish & Web Support
**Goal:** Add final polish and platform-specific features

- [ ] Create web fullscreen utility (`lib/core/utils/web_fullscreen.dart`)
- [ ] Add fullscreen toggle button (bottom-left, web only)
- [ ] Implement fullscreen functionality for web
- [ ] Add immersive mode for mobile Android
- [ ] Implement keyboard shortcuts (R=der, E=die, S=das, Space=restart, F=fullscreen)
- [ ] Add RawKeyboardListener to GameScreen
- [ ] Implement haptic feedback for mobile
- [ ] Add light impact on correct answer
- [ ] Add medium impact on wrong answer
- [ ] Add heavy impact on game over
- [ ] Add audio button to UI (🔊/🔇)
- [ ] Implement audio mute toggle (ready for future sounds)
- [ ] Persist mute preference in SharedPreferences
- [ ] Lock orientation to portrait (mobile)
- [ ] Handle browser tab visibility (pause/resume timer)
- [ ] Add error handling for CSV load failures
- [ ] Test edge cases (long nouns, rapid clicking, etc.)
- [ ] Add web meta tags to index.html
- [ ] Add favicon
- [ ] Test on Chrome, Firefox, Safari
- [ ] Test on Android mobile device
- [ ] Fix any console warnings or errors

**Status:** Completed  
**Blockers:** Phase 5 must be complete  
**Notes:**

**Test Checklist:**
- [ ] Fullscreen button appears on web (bottom-left)
- [ ] Fullscreen toggle works on web browsers
- [ ] Immersive mode works on Android
- [ ] Keyboard shortcut R selects "der"
- [ ] Keyboard shortcut E selects "die"
- [ ] Keyboard shortcut S selects "das"
- [ ] Keyboard shortcut F toggles fullscreen
- [ ] Space restarts game from game over
- [ ] Haptics trigger on mobile (correct/wrong/game over)
- [ ] Audio button toggles mute state
- [ ] Mute preference persists across sessions
- [ ] Orientation locked to portrait on mobile
- [ ] Timer pauses when tab loses focus (web)
- [ ] Timer resumes when tab regains focus
- [ ] Long nouns don't overflow container
- [ ] No console errors or warnings
- [ ] Game handles CSV load errors gracefully
- [ ] Rapid button clicking doesn't break game

**Git Commit (after completion):**
```bash
git add .
git commit -m "feat: implement Phase 6 - polish and web support

- Add fullscreen toggle for web (bottom-left button)
- Implement keyboard shortcuts (R/E/S for articles, F for fullscreen)
- Add haptic feedback for mobile (light/medium/heavy)
- Implement audio mute toggle (ready for future sound effects)
- Lock orientation to portrait on mobile
- Add browser tab visibility handling (pause/resume timer)
- Implement error handling for edge cases
- Add web meta tags and favicon
- Fix console warnings and errors"
```

---

## Deployment

### Web (GitHub Pages)
- [ ] Build for web: `flutter build web --release --base-href "/hangmensch/"`
- [ ] Test build locally
- [ ] Push to GitHub repository
- [ ] Deploy to gh-pages branch
- [ ] Verify live at github.io URL
- [ ] Test on multiple browsers

### Android APK
- [ ] Update version in pubspec.yaml
- [ ] Build APK: `flutter build apk --release`
- [ ] Test APK on physical device
- [ ] Upload APK to website for download
- [ ] Create download page with instructions

### iOS (Future)
- [ ] Configure Xcode signing (requires Mac + Apple Developer account)
- [ ] Build iOS: `flutter build ios --release`
- [ ] Test on iOS device via TestFlight
- [ ] Submit to App Store (optional)

**Git Commit (after deployment):**
```bash
git add .
git commit -m "deploy: release v1.0.0 to GitHub Pages and Android

- Build and deploy web version to GitHub Pages
- Generate Android APK for download
- Add deployment documentation"

git tag v1.0.0
git push origin main --tags
```

---

## Current Focus
**Working on:** Phase 6 - Polish & Web Support  
**Next up:** Final Deployment  

---

## Project Stats
- **Total Phases:** 6
- **Completed Phases:** 0
- **Estimated Total Tasks:** ~85
- **Completed Tasks:** 0

---

## Notes & Decisions

### Important Decisions Made:
- Using Riverpod for state management
- CustomPaint for gallows and hangmensch (not images)
- Floating limbs design (no torso connection)
- Skirt representation for gender inclusivity
- Center-constrained layout (max 600px) for web
- Keyboard shortcuts: R/E/S (mnemonic for deR/diE/daS)
- Audio optional for Phase 6 (can be added later)
- iOS support planned for future (not v1 requirement)

### Technical Notes:
- CSV has 3000 nouns with headers: article, noun, plural, translation
- Difficulty thresholds: 10 → medium, 30 → hard, 60 → infinite
- Timer durations: 6s (easy), 4s (medium), 2s (hard), 1s (infinite)
- 7 lives = 7 hangmensch body parts (1-to-1 mapping)
- High score persisted in SharedPreferences
- Word pool resets after all 3000 nouns shown

### Potential Future Enhancements (Post-v1):
- Sound effects (correct/wrong/timer/game over)
- Pronunciation audio for nouns (TTS)
- Streak tracking
- Accuracy percentage display
- Difficulty selection (let user choose starting difficulty)
- Daily challenge mode
- Leaderboard (requires backend)
- Additional word categories (verbs, adjectives)
- Light mode color theme option

---

**Last Updated:** [Date will be updated as you progress]
