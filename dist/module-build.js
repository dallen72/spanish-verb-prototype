(() => {
  // src/library.js
  var example = function() {
    console.log("hello world");
  };

  // src/first-excercise.js
  var FirstExcercise = class {
    /*
     * change the buttons of the matched element 
     */
    showTheMatch(element) {
      document.querySelector(".cell.selected").classList.add("correct");
      document.querySelector(".cell.selected").innerHTML = selectedPronoun + " " + selectedConjugation;
      document.querySelector(".cell.selected").classList.remove("selected");
      element.classList.add("correct");
      element.innerHTML = selectedPronoun + " " + selectedConjugation;
    }
    /*
     * check if all the verb conjugations are matched
     */
    allAreMatched() {
      return document.querySelectorAll(".cell.correct").length >= 12;
    }
    /*
     * set a new verb for the next problem
     */
    getNextProblem() {
      let completedVerbs = [];
      completedVerbs.push(verb.name);
      while (completedVerbs.includes(verb.name)) {
        verb = VERB_LIST[Math.floor(Math.random() * VERB_LIST.length)];
      }
      updatePreviousScoreElement();
      generateConjugationGameElements(verb);
    }
    /*
     * update the text for information on the last problem
     */
    updatePreviousScoreElement() {
      document.querySelector("h2.previousScore").innerHTML = "You got " + previousScore + " wrong on the last problem";
    }
    /*
     * handle click event for conjugation buttons
     */
    handleClickConjugation(event) {
      selectedConjugation = event.target.innerHTML;
      if (selectedPronoun != null) {
        if (this.verb.conjugations[selectedPronoun] == selectedConjugation) {
          showTheMatch(event.target);
          if (allAreMatched()) {
            showPopup();
            getNextProblem();
          }
          selectedConjugation = null;
          selectedPronoun = null;
          return;
        } else {
          previousScore += 1;
        }
      }
      const buttons = document.querySelectorAll(".cell");
      highlightOnlyOne(buttons, event.target);
      selectedConjugation = event.target.innerHTML;
    }
    /*
     * highlight only one button and remove highlight from all others
     * @param target - the button to highlight
     * @param buttons - the list of all buttons to remove highlight from
     */
    highlightOnlyOne(buttons, target) {
      buttons.forEach((button) => {
        button.classList.remove("selected");
      });
      target.classList.add("selected");
    }
    /*
     * show the temporary popup
     */
    showPopup() {
      const popup = document.getElementById("popup");
      popup.classList.add("show");
      setTimeout(function() {
        popup.classList.remove("show");
      }, 2e3);
    }
    /*
     * handle click event for pronoun buttons
     */
    _handleClickPronoun(event) {
      selectedPronoun = event.target.innerHTML.split("...")[0];
      if (selectedConjugation != null) {
        if (this.verb.conjugations[selectedPronoun] == selectedConjugation) {
          showTheMatch(event.target);
          if (allAreMatched()) {
            showPopup();
            getNextProblem();
          }
          selectedConjugation = null;
          selectedPronoun = null;
          return;
        } else {
          previousScore += 1;
        }
      }
      const buttons = document.querySelectorAll(".cell");
      highlightOnlyOne(buttons, event.target);
      selectedPronoun = event.target.innerHTML.split("...")[0];
    }
    /*
     * create a scores list for each verb from a verb list in the format of VERB_LIST
     * @param verbList - the list of verbs to create the scores list from
     * @return the scores list
     */
    createScoresListFromVerbList(verbList) {
      let verbScores = {};
      for (verbListObject in this.verbList) {
        let verbScoreObject = {};
        verbScoreObject.conjugationScores = {};
        for (conjugation in verbListObject.conjugations) {
          verbScoreObject.conjugationScores[conjugation] = 0;
        }
        verbScoreObject.score = 0;
        verbScores[verbListObject.name] = verbScoreObject;
      }
      return verbScores;
    }
    /*
     * get the key of an object by its value
     * @param object - the object to search
     * @param value - the value to search for
     * @return the key of the object
     */
    getKeyByValue(object, value) {
      return Object.keys(object).find((key) => object[key] === value);
    }
    /* 
     * show the second excercise
     */
    goToNextExcercise() {
      document.querySelector(".wordMatchingExcercise").style.display = "none";
      document.querySelector(".matchTheSentenceExcercise").style.display = "block";
    }
    /*
     * show the first excercise
     */
    goToFirstExcercise() {
      document.querySelector(".wordMatchingExcercise").style.display = "block";
      document.querySelector(".matchTheSentenceExcercise").style.display = "none";
    }
    constructor() {
      this.endingScores = {
        "ar": 0,
        "er": 0,
        "ir": 0
      };
      this.VERB_LIST = [
        {
          name: "Tener",
          conjugations: {
            yo: "tengo",
            tu: "tienes",
            el: "tiene",
            nosotros: "tenemos",
            vosotros: "ten\xE9is",
            ellos: "tienen"
          },
          ending: "er"
        },
        {
          name: "Hablar",
          conjugations: {
            yo: "hablo",
            tu: "hablas",
            el: "habla",
            nosotros: "hablamos",
            vosotros: "hablais",
            ellos: "hablan"
          },
          ending: "ar"
        },
        {
          name: "vivir",
          conjugations: {
            yo: "vivo",
            tu: "vives",
            el: "vive",
            nosotros: "vivimos",
            vosotros: "vivis",
            ellos: "viven"
          },
          ending: "ir"
        }
      ];
      this.verbScores = this.createScoresListFromVerbList(this.VERB_LIST);
      this.selectedPronoun;
      this.selectedConjugation;
      this.completedVerbs = [];
      this.previousScore = 0;
      this.verb = this.VERB_LIST[Math.floor(Math.random() * this.VERB_LIST.length)];
    }
    /*
     * generate the conjugation game html elements
     * @param verb - the verb to generate the elements for
     */
    generateConjugationGameElements(verb2) {
      document.querySelector("h2.verblabel").innerHTML = this.verb.name;
      let conjugationElements = document.querySelectorAll("div.conjugation.section div.cell");
      if (conjugationElements.length > 0) {
        for (let i = 0; i < conjugationElements.length; i++) {
          conjugationElements[i].remove();
        }
      }
      let pronounElements = document.querySelectorAll("div.cell.correct");
      for (let i = 0; i < pronounElements.length; i++) {
        pronounElements[i].innerHTML = pronounElements[i].innerHTML.split(" ")[0];
        pronounElements[i].classList.remove("correct");
      }
      let elementList = [];
      for (let i = 0; i < Object.keys(this.verb.conjugations).length; i++) {
        let conjugation2 = this.verb.conjugations[Object.keys(this.verb.conjugations)[i]];
        let keyName = this.getKeyByValue(this.verb.conjugations, conjugation2);
        let element = document.querySelector("." + Object.keys(this.verb.conjugations)[i] + "-conjugate");
        let cellElement = document.createElement("div");
        cellElement.classList.add("cell");
        cellElement.classList.add(keyName + "-conjugate");
        cellElement.classList.add("conjugate");
        cellElement.innerHTML = conjugation2;
        cellElement.onclick = function(event) {
          handleClickConjugation(event);
        };
        elementList.push(cellElement);
      }
      const randomizedList = elementList.sort(() => Math.random() - 0.5);
      for (let element in randomizedList) {
        document.querySelector("div.conjugation.section").appendChild(randomizedList[element]);
      }
    }
  };

  // src/main.js
  example();
  var firstExcercise = new FirstExcercise();
  document.addEventListener("DOMContentLoaded", function(event) {
    firstExcercise.generateConjugationGameElements();
    for (pronoun in firstExcercise.verb.conjugations) {
      let element = document.querySelector("." + pronoun + "-conjugate");
      element.innerHTML = firstExcercise.verb.conjugations[pronoun];
    }
  });
})();
