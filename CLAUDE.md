# Spanish Verb Conjugation Game - Project Guide

## Overview
A Godot 4.5 educational game for learning Spanish verb conjugations. Players match pronouns with conjugations across multiple game modes.

## Tech Stack
- **Engine**: Godot 4.5 (GDScript)
- **Resolution**: 1920x1080 (scales automatically via canvas_items stretch mode)
- **Main Scene**: `game/src/Main.tscn`

## Project Structure

```
spanish-verb-prototype/
├── game/                      # Godot project root
│   ├── project.godot          # Godot config (autoloads, window settings)
│   ├── src/
│   │   ├── Main.gd            # Main game controller, flow management
│   │   ├── Main.tscn          # Root scene with all UI
│   │   ├── VerbData.gd        # Static verb database (class_name VerbData)
│   │   ├── global/
│   │   │   ├── Global.tscn    # Autoload scene
│   │   │   └── game_progress_master.gd  # Global state (current_verb, completed_verbs, errors)
│   │   ├── header/
│   │   │   ├── ProgressIndicator.gd/.tscn  # Top-right status display
│   │   │   └── GameModeSelector.gd/.tscn   # Level selection buttons
│   │   ├── gametypes/
│   │   │   ├── pronounmatching/
│   │   │   │   ├── PronounMatching.gd/.tscn    # UI adapter for matching game
│   │   │   │   ├── PronounMatchSession.gd      # Domain model (match logic)
│   │   │   │   └── PronounButton.gd/.tscn      # Individual button controller
│   │   │   └── sentencecompletion/
│   │   │       └── SentenceCompletion.gd/.tscn # Fill-in-blank game mode
│   │   └── ui/
│   │       ├── Popup.gd/.tscn          # "Good Job!" completion popup
│   │       ├── ProgressScreen.gd/.tscn # Bar chart progress display
│   │       └── GlowEffect.gd           # Pulsing border effect
│   └── assets/                # Images, fonts, etc.
└── dev-server/                # Development utilities
```

## Key Files

### Main.gd (game/src/Main.gd)
Central controller that manages:
- Game mode switching (english_pronouns, spanish_pronouns, sentence_completion)
- Problem lifecycle (start_new_problem, on_problem_completed, on_error)
- UI updates and child scene coordination
- Popup and progress screen display

### game_progress_master.gd (game/src/global/game_progress_master.gd)
Global singleton (via autoload) storing:
- `current_verb: Dictionary` - Active verb being practiced
- `completed_verbs: Array` - List of completed verb names
- `total_errors: int` - Cumulative error count
- `previous_score: int` - Errors on last problem
- Button color configuration

Access via: `Global.get_node("GameProgressMaster")`

### VerbData.gd (game/src/VerbData.gd)
Static class with `VERB_LIST` constant containing 3 verbs:
- **Tener** (er ending): tengo, tienes, tiene, tenemos, tenéis, tienen
- **Hablar** (ar ending): hablo, hablas, habla, hablamos, habláis, hablan
- **Vivir** (ir ending): vivo, vives, vive, vivimos, vivís, viven

Each verb has: `name`, `conjugations`, `english_phrases`, `sentence_templates`, `ending`

Static methods: `get_random_verb()`, `get_available_verbs()`, `get_random_available_verb()`, `get_verb_by_name()`, `get_total_verb_count()`

## Game Flow

```
Game Start
    ↓
ProgressScreen (3 sec) ─── Shows bar chart of progress
    ↓
Main Game Screen ─── Header + GameType (PronounMatching or SentenceCompletion)
    ↓
Player completes problem
    ↓
Popup "Good Job!" (2 sec)
    ↓
ProgressScreen (3 sec)
    ↓
Next problem (loop)
```

## Game Modes

1. **English Pronouns** (Level 1-1): Match "I have" → "tengo"
2. **Spanish Pronouns** (Level 1-2): Match "yo" → "tengo"
3. **Sentence Completion** (Level 3): Match conjugation → sentence with blank

## Signal Flow

```
GameModeSelector.game_mode_changed
    → Main._on_game_mode_changed()
        → Show/hide game types, start_new_problem()

PronounMatchSession.session_completed
    → Main.on_problem_completed()
        → Popup → ProgressScreen → start_new_problem()

PronounMatchSession.match_failed
    → Main.on_error()
        → Increment errors, update progress indicator
```

## Common Patterns

### Accessing Global State
```gdscript
var game_progress = Global.get_node("GameProgressMaster")
var current_verb = game_progress.get_current_verb()
var completed = game_progress.get_completed_verbs()
```

### Adding a New Verb
Edit `VerbData.gd` and add to `VERB_LIST` array with all required fields.

### Adding a New Game Mode
1. Create scene in `game/src/gametypes/newmode/`
2. Add to Main.tscn as child
3. Add @onready reference in Main.gd
4. Handle in `_on_game_mode_changed()`
5. Add button to GameModeSelector

## UI Hierarchy (Main.tscn)

```
Main (Control)
├── Background (ColorRect - beige)
├── HeaderContainer (HBoxContainer)
│   ├── TitleSection (VBoxContainer)
│   │   ├── TitleLabel
│   │   ├── VerbLabel (dynamic instructions)
│   │   ├── PreviousScoreLabel
│   │   └── GameModeSelector
│   └── ProgressIndicator
├── TopHSeparator
├── PronounMatching (visible by default)
├── SentenceCompletion (hidden by default)
├── Popup (hidden, centered overlay)
└── ProgressScreen (hidden, full-screen overlay)
```

## Running the Game

```bash
# From game/ directory
godot --path .

# Or open in Godot editor and press F5
```

## Notes

- Viewport scaling is automatic - don't manually resize
- Press Escape in debug builds to quit
- All verbs must be completed before they reset
- Errors persist across problems until game restart
