# Spanish Verb Conjugation Game - Godot Version

TODO

# TODO: fix the "this game is not designed to run on your device" message in the browser on itch.io
# TODO: in Android chrome browser, make sure loads faster
# TODO: make sure buttons appear larger in chrome Android
# TODO: make sure the progress and intro screens take up the whole screen in Android chrome

# TODO: add the tutorial states to the progress screen. state is tutorial_showing_first_verb, then tutorial_showing_first_exercise, then showing_progress_normally 
# TODO: make the screens for the states. when the user clicks the buttons in the tutorial states, they are moved through the tutorial.
# TODO: create the lessons, so that the tutorial will have the lessons in them.
# TODO: remove the second and third exercise from the gameplay.
# TODO: when the user completes an exercise one time, a new verb is unlocked.
# TODO: when the user completes an exercise at 100% (english matching with one of the two verbs), a new exercise (spanish matching) is unlocked
# TODO: make the intro text move in like it's being typed, but fade in
# TODO: fix the conjugation exercise

# TODO: set up a local dev server for testing for mobile development. we can do one with godot already, but it seems to be blocking connections from devices on the same network.

- the exercises, when completed should add an icon to the list of verbs

- Add Lessons. The user does lessons before each exercise to unlock the exercise. Mnemonics are needed for each lesson.

- relationship, excercises to verbs are one to many:

- the player chooses an excercise and is shown the verb that has the lowest score for that excercise, and if there is a tie,
the lowest total score verb is shown for that excercise

- fix webgl error. can't run in linux on the browser

- make sure the initial button is green, that is selected

- make sure that the exercise that shows up when exiting the show progress screen after completing an exercise, is the same exercise that was just completed

- make sure the exercise button stays outlined when losing focus

- after alpha complete, refactor method to get the data, allow for a lot more data:
verb - tener, hablar, vivir
exercise - english_pronoun_matching, spanish_pronoun_matching, conjugation_matching


the user chooses an exercise and is shown the exercise with the correct verb populated.

the verb and the verb data for the exercise (conjugations for spanish_pronoun_matching,
					conjugations and english_phrases for english_pronoun_matching,

so we need three data entities: verbs, exercises, and excercise_data.

verb: 

exercise:

exercise_data:

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

## Development timeline:

## early alpha:
- Go to Spanish learning group
- share with CGDC virtual people

# after mid-alpha
- share with P&P
- share with family members
- share with CGDC
- find an artist

# after alpha complete
- share with Emily and Ryan (ryanrknight12@gmail.com) from FNSM
- share with David from FNSM (908 319 0880)
- be active in all relevant discords
- Kim from Calvary

# after beta complete
- setup a preorder
- share in all discords
