# Hangmensch - Setup & Implementation Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Antigravity Workflow](#antigravity-workflow)
4. [Implementation Phases](#implementation-phases)
5. [Testing Guidelines](#testing-guidelines)
6. [Git Workflow](#git-workflow)
7. [Deployment](#deployment)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- [ ] **Flutter SDK** (latest stable): https://flutter.dev/docs/get-started/install
- [ ] **Git**: https://git-scm.com/downloads
- [ ] **Code Editor**: VS Code (recommended) or Android Studio
- [ ] **Web Browser**: Chrome (for testing)
- [ ] **Antigravity Account**: https://antigravity.ai (or your IDE tool)

### Verify Installation
```bash
# Check Flutter
flutter doctor

# Check Git
git --version

# Expected output: Flutter 3.x.x, Git 2.x.x
```

### Optional (for mobile testing)
- [ ] Android Studio (for Android emulator)
- [ ] Physical Android device with USB debugging enabled
- [ ] Xcode (Mac only, for iOS - future)

---

## Initial Setup

### Step 1: Create Project Directory
```bash
# Create project folder
mkdir hangmensch
cd hangmensch

# Initialize Git
git init
git branch -M main
```

### Step 2: Add Project Files
Copy the following files into your `hangmensch` directory:
- `prd.md` (Product Requirements Document)
- `progress.md` (Implementation tracker)
- `SETUP_GUIDE.md` (this file)
- `README.md` (optional - for GitHub description)

Your directory structure should look like:
```
hangmensch/
├── prd.md
├── progress.md
├── SETUP_GUIDE.md
└── README.md (optional)
```

### Step 3: Create Initial Git Commit
```bash
git add .
git commit -m "docs: add project documentation (PRD, progress tracker, setup guide)"
```

### Step 4: Create GitHub Repository
1. Go to https://github.com/new
2. Repository name: `hangmensch`
3. Description: "German article learning game - hangman style"
4. Public or Private: Your choice
5. **DO NOT** initialize with README, .gitignore, or license
6. Click "Create repository"

### Step 5: Link Local Repository to GitHub
```bash
# Add GitHub remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/hangmensch.git

# Push initial commit
git push -u origin main
```

---

## Antigravity Workflow

### Understanding the Workflow

**The Loop (per phase):**
```
1. You → Antigravity: "Read prd.md and progress.md. Implement Phase X."
2. Antigravity → Creates files, writes code
3. Antigravity → Provides testing instructions + git commit message + progress notes
4. You → Test following instructions
5. You → Update progress.md (copy Antigravity's suggested notes)
6. You → Run git commit (copy Antigravity's suggested command)
7. You → CLOSE conversation (important for token efficiency)
8. Repeat for next phase
```

### Setting Up Antigravity Project

#### Option 1: Single Agent (Recommended for Beginners)

1. **Create a new project** in Antigravity
   - Project name: "Hangmensch"
   - Description: "German article learning game"

2. **Upload context files:**
   - Upload `prd.md` (primary reference)
   - Upload `progress.md` (tracks what's done)
   - These files will be available to the agent in every conversation

3. **Create your first agent:**
   - Agent name: "Hangmensch Builder"
   - Instructions: "You are a Flutter developer implementing the Hangmensch game. Always read prd.md for specifications and progress.md to see what's already done. Provide testing instructions, git commit messages, and progress notes after each phase."

#### Option 2: Multiple Specialized Agents (Advanced)

Create separate agents for different concerns:
- **Agent 1: "Data Layer"** - Handles Phase 1-2 (models, providers)
- **Agent 2: "UI Builder"** - Handles Phase 3 (layout, widgets)
- **Agent 3: "Custom Paint"** - Handles Phase 4 (gallows, hangmensch)
- **Agent 4: "Animations"** - Handles Phase 5 (game flow, timers)
- **Agent 5: "Polish"** - Handles Phase 6 (web support, keyboard, etc.)

*Note: Option 1 is simpler and recommended for this project.*

### Crafting Effective Prompts

**Template for each phase:**
```
Read prd.md and progress.md carefully.

Implement Phase [X]: [Phase Name]

Follow these specifications from prd.md:
- [Key spec 1]
- [Key spec 2]
- [Key spec 3]

When complete, provide:
1. Summary of what you built
2. List of files created/modified
3. Testing instructions (step-by-step)
4. Git commit message (ready to copy-paste)
5. Suggested notes for progress.md

Stop after completing this phase. Wait for my approval before proceeding.
```

**Example (Phase 1):**
```
Read prd.md and progress.md carefully.

Implement Phase 1: Project Setup & Data Layer

Follow these specifications from prd.md:
- Create feature-based folder structure (lib/features/game/, lib/core/)
- Add dependencies: flutter_riverpod ^2.5.1, shared_preferences ^2.2.3, csv ^6.0.0
- Add fonts: Quicksand and JetBrains Mono (download from Google Fonts)
- Create GermanNoun model with fromCsv factory
- Implement CSV parser utility
- Create Riverpod FutureProvider for loading nouns
- Place CSV file at assets/data/german_nouns.csv with 3000 nouns

When complete, provide:
1. Summary of what you built
2. List of files created/modified
3. Testing instructions (step-by-step)
4. Git commit message (ready to copy-paste)
5. Suggested notes for progress.md

Stop after completing this phase. Wait for my approval before proceeding.
```

### Managing Conversations

**Best Practices:**
- ✅ **One phase per conversation** - Keeps context focused
- ✅ **Close conversation after each phase** - Prevents token bloat
- ✅ **Start fresh for next phase** - New conversation with updated progress.md
- ✅ **Be specific** - Reference exact section numbers in prd.md
- ✅ **Ask for clarification** - If agent output is unclear

**Anti-Patterns:**
- ❌ Don't say "build the whole game" - too broad
- ❌ Don't keep conversations running across multiple phases
- ❌ Don't forget to update progress.md between phases
- ❌ Don't skip testing - always verify before moving on

---

## Implementation Phases

### Phase 1: Project Setup & Data Layer

**Objective:** Create project structure, load CSV data

**Prompt for Antigravity:**
```
Read prd.md and progress.md carefully.

Implement Phase 1: Project Setup & Data Layer

Create the Flutter project structure following Section 2 (Architecture) in prd.md:
- lib/features/game/models/
- lib/features/game/providers/
- lib/core/constants/
- lib/core/utils/
- assets/data/

Add dependencies from prd.md Section 1:
- flutter_riverpod: ^2.5.1
- shared_preferences: ^2.2.3
- csv: ^6.0.0

Configure fonts in pubspec.yaml:
- Quicksand (Regular, SemiBold, Bold)
- JetBrains Mono (Regular)

Implement:
1. GermanNoun model (Section 3) with fromCsv factory
2. CSV parser utility in lib/core/utils/csv_parser.dart
3. Riverpod FutureProvider for loading nouns

Create CSV file at assets/data/german_nouns.csv with headers:
article,noun,plural,translation

Include at least 50 sample nouns for testing (I'll replace with 3000 later).

When complete, provide:
1. Summary of files created
2. Testing instructions
3. Git commit message
4. Progress notes

Stop after Phase 1. Wait for approval.
```

**Your Testing Steps:**
1. Run `flutter pub get`
2. Run the app in debug mode
3. Check console for "Loaded X nouns" message
4. Verify no errors in debug console
5. Print first 10 nouns to verify correct parsing

**After Testing:**
1. Update `progress.md` - check off Phase 1 tasks, add notes
2. Run the git commit Antigravity provided
3. Push to GitHub: `git push origin main`
4. Close Antigravity conversation

---

### Phase 2: Core Game Logic

**Objective:** Implement game state management

**Prompt for Antigravity:**
```
Read prd.md and progress.md carefully.

Implement Phase 2: Core Game Logic

Refer to Section 3 (Data Models) and Section 4 (Game Mechanics) in prd.md.

Implement:
1. GameState model with ALL fields from Section 3
2. Three enums: GameStatus, Difficulty, HangmenschPart
3. Computed properties: maxTime (returns 6/4/2/1 based on difficulty), mistakeCount (7 - lives)
4. GameNotifier (Riverpod StateNotifier) with methods:
   - selectArticle(String article) - handles correct/wrong/timeout
   - startGame() - initializes new game
   - nextNoun() - loads next word from pool
   - checkDifficultyIncrease() - checks 10/30/60 thresholds
5. High score provider using SharedPreferences
6. Word pool management (shuffle on start, remove used, reset after 3000)
7. Timer logic (decrement every 100ms, pause/resume capability)

Follow difficulty progression from Section 4:
- Easy (6s) → Medium (4s) at 10 correct
- Medium → Hard (2s) at 30 correct
- Hard → Infinite (1s) at 60 correct

When complete, provide:
1. Summary of files created
2. Testing instructions (manual state verification)
3. Git commit message
4. Progress notes

Stop after Phase 2.
```

**Your Testing Steps:**
1. Run the app
2. Manually test state transitions in debug console
3. Verify difficulty increases at correct thresholds
4. Verify high score persists (restart app and check)
5. Verify word pool management (no immediate repeats)
6. Check timer decrements correctly

**After Testing:**
1. Update `progress.md`
2. Run git commit
3. Push to GitHub
4. Close conversation

---

### Phase 3: UI Foundation

**Objective:** Build basic UI layout

**Prompt for Antigravity:**
```
Read prd.md and progress.md carefully.

Implement Phase 3: UI Foundation

Refer to Section 5 (UI Specifications) in prd.md.

Create:
1. GameScreen scaffold (lib/features/game/game_screen.dart)
   - Black background
   - SafeArea
   - Center-constrained to max 600px width
   - Responsive layout from Section 5

2. Constants files:
   - lib/core/constants/ui_colors.dart (Section 5 color palette)
   - lib/core/constants/layout_constants.dart (Section 5 spacing values)
   - lib/core/constants/ui_elements.dart (Section 5 icon definitions)

3. App theme (lib/core/theme/app_theme.dart)
   - Configure Quicksand for text
   - Configure JetBrains Mono for numbers

4. TopBar widget (lib/features/game/widgets/top_bar.dart)
   - High score: 🏆 + number (left)
   - Current score: 📊 + number (center)
   - Lives: ❤️ + number (right)

5. ArticleButton widget (lib/features/game/widgets/article_button.dart)
   - Yellow outline (3px border)
   - Rounded corners (12px radius)
   - Quicksand Bold, 28px
   - Press feedback animation
   - Three instances at bottom: "der", "die", "das"

Follow exact layout from Section 5 (Screen Layout diagram).

When complete, provide:
1. Summary of files
2. Testing instructions (visual verification)
3. Git commit message
4. Progress notes

Stop after Phase 3.
```

**Your Testing Steps:**
1. Run the app
2. Verify layout on mobile size (375px width in browser DevTools)
3. Verify layout on desktop (centered at 600px max)
4. Check all icons display correctly
5. Verify fonts (numbers = JetBrains Mono, text = Quicksand)
6. Check colors match German flag theme
7. Test button press feedback

**After Testing:**
1. Update `progress.md`
2. Run git commit
3. Push to GitHub
4. Close conversation

---

### Phase 4: Custom Painters

**Objective:** Implement gallows and hangmensch

**Prompt for Antigravity:**
```
Read prd.md and progress.md carefully.

Implement Phase 4: Custom Painters

Refer to Section 7 (CustomPaint Specifications) in prd.md.

Create:
1. lib/core/constants/gallows_specs.dart
   - Define ALL coordinates from Section 7
   - Gallows: base, pole, bar (asymmetric T), rope
   - Hangmensch: head, leftArm, rightArm, leftLeg, skirt (triangle), rightLeg, eyes (X X)

2. lib/features/game/widgets/gallows_painter.dart
   - CustomPainter for gallows structure
   - Gold color (#FFCE00)
   - 4px stroke width
   - Opacity parameter for fade-in animation
   - Drawing methods for each part

3. lib/features/game/widgets/hangmensch_painter.dart
   - CustomPainter for hangmensch body
   - Red color (#DD0000)
   - 3px stroke width
   - Draws parts based on mistakeCount (0-7)
   - Floating limbs (no torso)
   - Skirt drawn as Path (triangle shape)
   - Swing animation on game over (8px horizontal, 2px vertical bob)

4. Sequential fade-in animation for gallows during idle state
   - Base (300ms) → pause 200ms → Pole (300ms) → pause 200ms → Bar (300ms) → pause 200ms → Rope (300ms)

5. Trace-in animation for body parts (400ms each with easeInOut curve)

Integrate painters into GameScreen widget.

When complete, provide:
1. Summary of files
2. Testing instructions (visual verification of each body part)
3. Git commit message
4. Progress notes

Stop after Phase 4.
```

**Your Testing Steps:**
1. Run the app
2. Verify gallows fades in sequentially during idle
3. Verify asymmetric T shape (small left, long right)
4. Verify rope position (near right end, not flush)
5. Manually trigger mistakes (via provider) and verify each body part:
   - 1st mistake: Head appears
   - 2nd: Left arm
   - 3rd: Right arm
   - 4th: Left leg (straight)
   - 5th: Skirt (triangle shape)
   - 6th: Right leg
   - 7th: Eyes (X X)
6. Verify floating limbs don't touch
7. Test swing animation on game over
8. Check all coordinates and proportions

**After Testing:**
1. Update `progress.md`
2. Run git commit
3. Push to GitHub
4. Close conversation

---

### Phase 5: Game Flow & Animations

**Objective:** Implement full game with animations

**Prompt for Antigravity:**
```
Read prd.md and progress.md carefully.

Implement Phase 5: Game Flow & Animations

Refer to Section 6 (Animations & Timing) in prd.md.

Create:
1. lib/core/constants/animation_durations.dart
   - ALL duration constants from Section 6

2. lib/features/game/widgets/circular_timer.dart
   - Circular progress indicator (80px diameter, 6px stroke)
   - Timer number in center (JetBrains Mono, 32px)
   - Color changes:
     * Yellow (#FFCE00) when > 2s
     * Orange (#FF8C00) when ≤ 2s
     * Red (#DD0000) when ≤ 1s
   - Updates every 100ms
   - Depletes clockwise

3. lib/features/game/widgets/noun_display.dart
   - Shows "Tap → Los!" in idle state
   - Shows "3", "2", "1" countdown (300ms each, pulse animation)
   - Shows noun (Quicksand, 48px, white) + translation below (20px, gray, 60% opacity)
   - Article slides in from left (500ms, easeOutCubic)
   - Noun + translation shift right when article appears (AnimatedContainer)
   - Article color: yellow if correct, red if wrong
   - Hold for 1.5s after reveal
   - Fade out (300ms) to next noun

4. Button feedback (in ArticleButton widget):
   - Correct: Pulse yellow (300ms, easeInOut)
   - Wrong: Shake + red fill (300ms, elasticIn)
   - Show correct: Bounce + yellow highlight (500ms)
   - Timeout: All buttons pulse red (200ms)
   - Disable buttons during animations

5. lib/features/game/widgets/game_over_dialog.dart
   - Tombstone emoji 🪦
   - Final score: 📊 + number
   - High score: 🏆 + number (with ✨ if new high score)
   - Restart button: 🔄 icon only
   - Fade + slide up animation (400ms, easeOutBack)

6. Difficulty increase animation:
   - Timer does double-pulse (400ms) when difficulty changes

7. Wire ALL animation sequences from Section 6:
   - Sequence 1: Initial gallows fade-in (done in Phase 4)
   - Sequence 2: Game start from idle
   - Sequence 3: Correct answer
   - Sequence 4: Wrong answer
   - Sequence 5: Timer expires
   - Sequence 6: Game over
   - Sequence 7: Restart
   - Sequence 8: Difficulty increase

Integrate all widgets into GameScreen and wire to game provider.

When complete, provide:
1. Summary of files
2. Full game loop testing instructions
3. Git commit message
4. Progress notes

Stop after Phase 5.
```

**Your Testing Steps:**
1. Run the app and play a complete game
2. Test idle state → tap → countdown → game starts
3. Test correct answer flow (pulse, slide, pause, next noun)
4. Test wrong answer flow (shake, bounce, gallows part, slide, pause)
5. Test timer expiry (all buttons pulse, correct article shows)
6. Verify 1.5s learning pause after each answer
7. Test difficulty progression (10, 30, 60 correct answers)
8. Verify timer pulse on difficulty increase
9. Test game over (all lives lost, dialog appears, swing animation)
10. Test new high score (sparkle appears)
11. Test restart (countdown, new game)
12. Verify all animations are smooth (no jank)
13. Verify buttons disabled during animations
14. Play 5-10 full games to ensure stability

**After Testing:**
1. Update `progress.md`
2. Run git commit
3. Push to GitHub
4. Close conversation

---

### Phase 6: Polish & Web Support

**Objective:** Add platform-specific features and polish

**Prompt for Antigravity:**
```
Read prd.md and progress.md carefully.

Implement Phase 6: Polish & Web Support

Refer to Section 10 (Web-Specific Requirements) in prd.md.

Implement:
1. lib/core/utils/web_fullscreen.dart
   - Detect if running on web (kIsWeb)
   - Toggle fullscreen using dart:html
   - Track fullscreen state

2. Fullscreen button (GameScreen, positioned bottom-left)
   - Show only on web (if kIsWeb)
   - Icon: fullscreen / fullscreen_exit
   - Yellow color, 28px
   - Positioned: left 16px, bottom 16px

3. Keyboard shortcuts (RawKeyboardListener in GameScreen):
   - R → select "der"
   - E → select "die"
   - S → select "das"
   - F → toggle fullscreen
   - Space → restart (when game over)
   - Only active when GameStatus.playing or gameOver

4. Immersive mode for mobile (Android):
   - SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)
   - Call in main.dart

5. Haptic feedback (mobile only, not web):
   - Correct answer: HapticFeedback.lightImpact()
   - Wrong answer: HapticFeedback.mediumImpact()
   - Game over: HapticFeedback.heavyImpact()

6. Audio button (in timer row):
   - Icon: volume_off / volume_up
   - Toggle mute state
   - Persist preference in SharedPreferences
   - Wire to game provider (no actual sounds yet, just state)

7. Portrait mode lock (mobile):
   - SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])

8. Browser tab visibility handling:
   - Pause timer when tab hidden
   - Resume when tab visible again
   - Use WidgetsBindingObserver

9. Error handling:
   - CSV load failure → Show error dialog with retry
   - Invalid CSV entries → Skip and log
   - Long nouns → Use FittedBox in NounDisplay

10. Web meta tags (web/index.html):
    - Add description, og:title, og:description
    - Add favicon

11. Fix any console warnings or errors

When complete, provide:
1. Summary of all features added
2. Testing checklist (web + mobile + keyboard)
3. Git commit message
4. Progress notes

Stop after Phase 6.
```

**Your Testing Steps:**

**Web Testing:**
1. Run in Chrome, Firefox, Safari
2. Test fullscreen toggle (bottom-left button)
3. Test keyboard shortcuts (R, E, S, F, Space)
4. Test tab focus loss/gain (timer pauses/resumes)
5. Check meta tags (view page source)
6. Verify favicon appears

**Mobile Testing (Android):**
1. Build and install APK on device
2. Verify immersive mode (no status/nav bars)
3. Test haptic feedback (correct, wrong, game over)
4. Verify portrait lock (can't rotate)
5. Test audio mute toggle persistence

**Edge Cases:**
1. Long noun (>20 characters) → Check it fits
2. Rapid button clicking → No crashes
3. CSV load error → Error dialog appears
4. Restart during animation → No issues

**After Testing:**
1. Update `progress.md` - mark Phase 6 complete!
2. Run git commit
3. Push to GitHub
4. Close conversation
5. **Ready for deployment!**

---

## Testing Guidelines

### General Testing Principles
- **Test immediately after each phase** - Don't accumulate untested code
- **Test on target platform** - Web in browser, mobile on device if possible
- **Check console** - No errors or warnings
- **Visual verification** - Does it look right?
- **Interaction testing** - Does it feel right?
- **Edge cases** - Try to break it

### Testing Tools

**Flutter DevTools:**
```bash
# Run with DevTools
flutter run -d chrome --dart-define=FLUTTER_WEB_USE_SKIA=true
```

**Hot Reload:**
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Speeds up testing iterations

**Browser DevTools:**
- F12 in Chrome/Firefox
- Check console for errors
- Use mobile emulation (responsive testing)
- Network tab (check CSV loads)

### What to Test Per Phase

**Phase 1:**
- CSV loads without errors
- Correct number of nouns parsed
- Fields populated correctly (article, noun, translation)

**Phase 2:**
- State initializes correctly
- Article selection updates state
- Score/lives change as expected
- Difficulty increases at thresholds
- High score persists
- Word pool doesn't repeat

**Phase 3:**
- Layout responsive (mobile, tablet, desktop)
- Icons display correctly
- Colors match spec
- Fonts render correctly
- Buttons respond to press

**Phase 4:**
- Gallows draws correctly (proportions, coordinates)
- All 7 body parts appear in order
- Animations smooth
- Swing works on game over

**Phase 5:**
- Full game loop works end-to-end
- All animations smooth and timed correctly
- Timer counts down and changes color
- Article reveal works correctly
- Dialog appears on game over
- Restart works

**Phase 6:**
- Web features work (fullscreen, keyboard)
- Mobile features work (haptics, immersive mode)
- Edge cases handled
- No console errors

---

## Git Workflow

### Commit After Each Phase

Antigravity will provide a ready-to-use commit message after each phase. Example:

```bash
# Antigravity provides:
git add .
git commit -m "feat: implement Phase 1 - data models and CSV parsing

- Add GermanNoun model with article, noun, plural, translation
- Implement CSV parser for german_nouns.csv
- Set up Riverpod provider for nouns loading
- Add dependencies: riverpod, csv, shared_preferences
- Configure fonts: Quicksand and JetBrains Mono"

# You run it, then:
git push origin main
```

### Commit Message Format

Following **Conventional Commits:**
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring (no behavior change)
- `style:` - UI/styling changes
- `docs:` - Documentation only
- `test:` - Adding tests
- `chore:` - Tooling, config, etc.

### Branching Strategy (Optional)

For safer development:
```bash
# Create feature branch for each phase
git checkout -b phase-1-data-layer

# Work on phase, commit

# Merge back to main when tested
git checkout main
git merge phase-1-data-layer
git push origin main
```

### Tagging Releases

After Phase 6 (deployment):
```bash
git tag v1.0.0
git push origin main --tags
```

---

## Deployment

### Prerequisites for Deployment
- [ ] All 6 phases complete
- [ ] All tests passing
- [ ] No console errors
- [ ] Tested on multiple browsers/devices
- [ ] GitHub repository set up

---

### Web Deployment (GitHub Pages)

#### Step 1: Build for Web
```bash
# Build optimized web version
flutter build web --release --base-href "/hangmensch/"

# Note: Replace "hangmensch" with your repo name if different
```

#### Step 2: Test Build Locally
```bash
# Serve the build folder locally
cd build/web
python3 -m http.server 8000

# Open http://localhost:8000 in browser
# Test the production build
```

#### Step 3: Deploy to GitHub Pages

**Option A: Manual Deployment**
```bash
# Install gh-pages npm package (one-time)
npm install -g gh-pages

# Deploy build/web to gh-pages branch
gh-pages -d build/web

# Or manually:
git checkout -b gh-pages
cp -r build/web/* .
git add .
git commit -m "deploy: web version v1.0.0"
git push origin gh-pages
```

**Option B: GitHub Actions (Automated)**

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - run: flutter pub get
      - run: flutter build web --release --base-href "/hangmensch/"
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

Commit and push this file - auto-deploys on every push to main!

#### Step 4: Enable GitHub Pages

1. Go to your repo on GitHub
2. Settings → Pages
3. Source: Deploy from branch
4. Branch: `gh-pages` → `/ (root)` → Save
5. Wait 2-3 minutes
6. Your game will be live at: `https://YOUR_USERNAME.github.io/hangmensch/`

#### Step 5: Test Live Site
- Open the GitHub Pages URL
- Test on Chrome, Firefox, Safari
- Test fullscreen, keyboard shortcuts
- Verify all features work

---

### Android Deployment (APK)

#### Step 1: Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

#### Step 2: Build APK
```bash
# Build release APK
flutter build apk --release

# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

#### Step 3: Test APK
```bash
# Install on connected device
flutter install

# Or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

Test thoroughly:
- [ ] Game plays correctly
- [ ] Haptics work
- [ ] Immersive mode works
- [ ] Portrait lock works
- [ ] No crashes

#### Step 4: Upload to Website

1. Copy APK to your website's download folder
2. Rename to `hangmensch-v1.0.0.apk`
3. Create download page with:
   - Game description
   - Screenshot
   - Download link
   - Installation instructions

**Installation Instructions for Users:**
```markdown
### How to Install (Android)

1. Download hangmensch-v1.0.0.apk
2. Open the downloaded file
3. If prompted, enable "Install from Unknown Sources" in Settings
4. Tap "Install"
5. Open the app and start playing!
```

---

### iOS Deployment (Future - Optional)

**Requirements:**
- Mac computer
- Xcode installed
- Apple Developer account ($99/year)

**Steps (high-level):**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing (Team, Bundle ID)
3. Build: `flutter build ios --release`
4. Archive in Xcode (Product → Archive)
5. Upload to App Store Connect
6. Submit for TestFlight beta testing
7. Submit for App Store review

*Note: iOS deployment not required for v1. Consider after web/Android success.*

---

### Adding Custom Domain (Optional)

If you want `hangmensch.yourdomain.com` instead of GitHub Pages URL:

1. **Buy domain** (Namecheap, Google Domains, etc.)

2. **Add CNAME file** to `build/web/`:
   ```
   hangmensch.yourdomain.com
   ```

3. **Configure DNS** at your domain registrar:
   - Type: CNAME
   - Name: hangmensch
   - Value: YOUR_USERNAME.github.io

4. **Enable HTTPS** in GitHub Pages settings

5. Wait for DNS propagation (up to 48 hours)

---

## Troubleshooting

### Common Issues & Solutions

#### Issue: "Could not find package 'X'"
**Solution:**
```bash
flutter pub get
flutter pub upgrade
```

#### Issue: Fonts not loading
**Solution:**
- Check `pubspec.yaml` indentation (YAML is sensitive!)
- Verify font files in `fonts/` directory
- Run `flutter clean` then `flutter pub get`

#### Issue: Web build fails
**Solution:**
```bash
# Clear cache
flutter clean

# Rebuild
flutter build web --release
```

#### Issue: Hot reload not working
**Solution:**
```bash
# Hot restart instead
flutter run
# Then press 'R' (capital) in terminal
```

#### Issue: "Unsupported operation: Platform._operatingSystem"
**Solution:**
- You're using `Platform` from `dart:io` in web code
- Use `kIsWeb` from `package:flutter/foundation.dart` instead

#### Issue: Keyboard shortcuts not working
**Solution:**
- Check `RawKeyboardListener` is wrapped around your widget
- Verify `focusNode` is created and focused
- Test in browser (not mobile emulator)

#### Issue: Haptics not working
**Solution:**
- Only works on physical devices (not emulators)
- Check device has haptic motor (some cheap phones don't)
- Verify `HapticFeedback` calls wrapped in `if (!kIsWeb)`

#### Issue: CSV not loading
**Solution:**
- Check file path: `assets/data/german_nouns.csv`
- Verify `pubspec.yaml` has:
  ```yaml
  flutter:
    assets:
      - assets/data/german_nouns.csv
  ```
- Run `flutter clean` then `flutter pub get`

#### Issue: Game lag/jank
**Solution:**
- Check animations use `const` where possible
- Verify no rebuilds in hot path
- Use `flutter run --profile` to check performance
- Consider using `RepaintBoundary` for custom painters

#### Issue: GitHub Pages shows 404
**Solution:**
- Check `gh-pages` branch exists and has files
- Verify GitHub Pages enabled in repo settings
- Check `base-href` matches repo name in build command
- Wait 2-3 minutes for deployment

#### Issue: APK crashes on launch
**Solution:**
```bash
# Check logs
adb logcat

# Common issue: ProGuard shrinking too much
# Add to android/app/build.gradle:
buildTypes {
    release {
        minifyEnabled false
        shrinkResources false
    }
}
```

---

### Getting Help

**Resources:**
- **Flutter Docs:** https://docs.flutter.dev
- **Riverpod Docs:** https://riverpod.dev
- **Stack Overflow:** Tag questions with `flutter` and `dart`
- **Flutter Discord:** https://discord.gg/flutter

**Debugging Tips:**
- Use `print()` statements liberally
- Check Flutter DevTools (performance, network, logs)
- Read error messages carefully (they're usually helpful!)
- Search error messages on Google/Stack Overflow
- Ask Antigravity to debug specific issues

---

## Post-Deployment Checklist

After successful deployment:

### Verification
- [ ] Web version live and working
- [ ] APK downloadable and installable
- [ ] Tested on multiple devices/browsers
- [ ] All features working in production
- [ ] No console errors

### Documentation
- [ ] README.md updated with live links
- [ ] Screenshots added to README
- [ ] Installation instructions clear
- [ ] License file added (if open source)

### Promotion
- [ ] Share on social media
- [ ] Post on Reddit (r/flutter, r/German, r/languagelearning)
- [ ] Add to portfolio website
- [ ] Consider writing blog post about the process

### Maintenance
- [ ] Monitor for bug reports
- [ ] Plan future enhancements (sound, streaks, etc.)
- [ ] Keep Flutter SDK updated
- [ ] Respond to user feedback

---

## Next Steps After v1

### Potential Enhancements
1. **Sound effects** (Phase 6 partial - just needs audio files)
2. **Pronunciation audio** (TTS for nouns)
3. **Streak tracking** (motivational)
4. **Accuracy percentage** (learning analytics)
5. **Difficulty selection** (let user choose starting level)
6. **Daily challenge mode** (curated word lists)
7. **Leaderboard** (requires backend/Firebase)
8. **Additional word categories** (verbs, adjectives)
9. **Light mode** (alternative color theme)
10. **Achievements/badges** (gamification)

### Technical Improvements
- Unit tests (core game logic)
- Widget tests (UI components)
- Integration tests (full game flows)
- Performance profiling and optimization
- Accessibility improvements (screen reader support)
- Internationalization (UI in multiple languages)

---

## Summary

You've successfully planned and are ready to build Hangmensch! 🎉

**Recap of the process:**
1. ✅ Set up project structure
2. ✅ Understand Antigravity workflow
3. ✅ Have clear implementation phases (1-6)
4. ✅ Know how to test at each stage
5. ✅ Have git workflow defined
6. ✅ Know how to deploy (web + Android)

**Your immediate next steps:**
1. Create GitHub repository
2. Set up Antigravity project
3. Start Phase 1 with the provided prompt
4. Test, commit, repeat through Phase 6
5. Deploy and share!

**Remember:**
- One phase at a time
- Test thoroughly before moving on
- Update progress.md after each phase
- Close Antigravity conversations to save tokens
- Commit after each successful phase
- Have fun! This is a learning project 🚀

Good luck, and enjoy building Hangmensch! 🇩🇪🎮

---

**Questions or Issues?**
Refer back to this guide, check the PRD for specifications, or ask Antigravity for clarification on specific technical details.
