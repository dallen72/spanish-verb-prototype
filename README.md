# Spanish Verb Conjugation Game - Godot Version

TODO

- make pronoun buttons lighter (look like conjugation buttons by default)

- refactor, look at code

- make sure works with English and Spanish gametypes

- fix outline, make look better

- simple fixes
	- need to change what shows on the popup button when completing a level
	- have a progress screen that shows bars that increase

- plan - what will be the MVP?

- design

--------------------------------------------------------------------

This is a Godot conversion of the HTML Spanish verb conjugation matching game. Players match Spanish pronouns (yo, tu, el, nosotros, vosotros, ellos) with their corresponding verb conjugations.

## How to Play

1. **Objective**: Match each Spanish pronoun with its correct verb conjugation
2. **Gameplay**: 
   - Click on a pronoun button (left side) to select it
   - Click on a conjugation button (right side) to match it
   - Correct matches turn blue and become disabled
   - Incorrect attempts are tracked in your score
3. **Progression**: Complete all 6 matches to finish the verb, then move to the next random verb

## Features

- **Three Verbs**: Tener (er), Hablar (ar), and Vivir (ir)
- **Visual Feedback**: 
  - Yellow buttons (default)
  - Green buttons (selected)
  - Blue buttons (correct matches)
- **Scoring**: Tracks incorrect attempts per problem
- **Random Selection**: Verbs are selected randomly, avoiding recently completed ones
- **Completion Popup**: Shows "Good Job!" message when all matches are made

## Running the Game

### Desktop (Windows/Linux/macOS)

1. Open the project in Godot 4.2+
2. Run the main scene (`Main.tscn`)
3. The game window will open at 1024x600 resolution

## Game Structure

- `Main.gd`: Contains all game logic, verb data, and UI interactions
- `Main.tscn`: The main scene with UI layout and controls
- `project.godot`: Godot project configuration

## Verb Data

The game includes three Spanish verbs with their conjugations:

- **Tener** (to have): tengo, tienes, tiene, tenemos, tenéis, tienen
- **Hablar** (to speak): hablo, hablas, habla, hablamos, hablais, hablan  
- **Vivir** (to live): vivo, vives, vive, vivimos, vivis, viven

Enjoy learning Spanish verb conjugations!
