
import { example } from "./library.js";
import { FirstExcercise } from "./first-excercise.js"

example();
const firstExcercise = new FirstExcercise();


/*
 * main function to run when the page is loaded
 */
document.addEventListener("DOMContentLoaded", function(event) { 
  firstExcercise.generateConjugationGameElements();
  // init pronoun part of game board
  for (pronoun in firstExcercise.verb.conjugations) {
    let element = document.querySelector('.' + pronoun + '-conjugate');
    element.innerHTML = firstExcercise.verb.conjugations[pronoun];
  }
});


