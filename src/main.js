
import { example } from "./library.js";
import firstExcercise from "./first-excercise.js"

example();
generateConjugationGameElements = firstExcercise.generateConjugationGameElements;
verb = firstExcercise.verb;
handleClickPronoun = firstExcercise.handleClickPronoun;
previousScore = firstExcercise.previousScore;

/*
 * main function to run when the page is loaded
 */
document.addEventListener("DOMContentLoaded", function(event) { 
  // init pronoun part of game board
  for (pronoun in verb.conjugations) {
    let element = document.querySelector('.' + pronoun + '-conjugate');
    element.innerHTML = verb.conjugations[pronoun];
  }
});


