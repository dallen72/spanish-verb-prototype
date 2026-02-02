# Spanish Verb Conjugation Game - Godot Version

TODO

- verb list
- excercise list
relationship, excercises to verbs are one to many:
- the player chooses an excercise and is shown the verb that has the lowest score for that excercise, and if there is a tie,
the lowest total score verb is shown for that excercise


--------------------------------------------------------------------

Learn spanish with the conjugation game. Progress through words and conjugations with excercises that you choose, viewing your progress as you go along.

Match spanish pronouns with their corresponding verb conjugations.

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
- **Visual Feedback**: different colors for different statuses of the buttons
- **Scoring**: Tracks incorrect attempts per problem
- **Pseudo-Random Selection**: Verbs are selected based off the priority.

## Running the Game

### Desktop (Windows/Linux/macOS)

1. Open the project in Godot 4.5
2. Run the main scene (`Main.tscn`)
3. The game window will open at 1920 x 1080 resolution

## Game Structure

- `Main.gd`: Contains all game logic, verb data, and UI interactions
- `project.godot`: Godot project configuration

## Verb Data

The game includes three Spanish verbs with their conjugations:

- **Tener** (to have): tengo, tienes, tiene, tenemos, tenéis, tienen
- **Hablar** (to speak): hablo, hablas, habla, hablamos, hablais, hablan  
- **Vivir** (to live): vivo, vives, vive, vivimos, vivis, viven