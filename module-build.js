(() => {
  // library.js
  var example = function() {
    console.log("hello world");
  };

  // first-excercise.js
  function showTheMatch(element) {
    document.querySelector(".cell.selected").classList.add("correct");
    document.querySelector(".cell.selected").innerHTML = selectedPronoun + " " + selectedConjugation;
    document.querySelector(".cell.selected").classList.remove("selected");
    element.classList.add("correct");
    element.innerHTML = selectedPronoun + " " + selectedConjugation;
  }
  function allAreMatched() {
    return document.querySelectorAll(".cell.correct").length >= 12;
  }
  function getNextProblem() {
    let completedVerbs = [];
    completedVerbs.push(verb2.name);
    while (completedVerbs.includes(verb2.name)) {
      verb2 = VERB_LIST[Math.floor(Math.random() * VERB_LIST.length)];
    }
    updatePreviousScoreElement();
    generateConjugationGameElements(verb2);
  }
  function updatePreviousScoreElement() {
    document.querySelector("h2.previousScore").innerHTML = "You got " + previousScore2 + " wrong on the last problem";
  }
  function handleClickConjugation(event) {
    selectedConjugation = event.target.innerHTML;
    if (selectedPronoun != null) {
      if (verb2.conjugations[selectedPronoun] == selectedConjugation) {
        showTheMatch(event.target);
        if (allAreMatched()) {
          showPopup();
          getNextProblem();
        }
        selectedConjugation = null;
        selectedPronoun = null;
        return;
      } else {
        previousScore2 += 1;
      }
    }
    const buttons = document.querySelectorAll(".cell");
    highlightOnlyOne(buttons, event.target);
    selectedConjugation = event.target.innerHTML;
  }
  function highlightOnlyOne(buttons, target) {
    buttons.forEach((button) => {
      button.classList.remove("selected");
    });
    target.classList.add("selected");
  }
  function showPopup() {
    const popup = document.getElementById("popup");
    popup.classList.add("show");
    setTimeout(function() {
      popup.classList.remove("show");
    }, 2e3);
  }
  function handleClickPronoun2(event) {
    selectedPronoun = event.target.innerHTML.split("...")[0];
    if (selectedConjugation != null) {
      if (verb2.conjugations[selectedPronoun] == selectedConjugation) {
        showTheMatch(event.target);
        if (allAreMatched()) {
          showPopup();
          getNextProblem();
        }
        selectedConjugation = null;
        selectedPronoun = null;
        return;
      } else {
        previousScore2 += 1;
      }
    }
    const buttons = document.querySelectorAll(".cell");
    highlightOnlyOne(buttons, event.target);
    selectedPronoun = event.target.innerHTML.split("...")[0];
  }
  function createScoresListFromVerbList(verbList) {
    let verbScores2 = {};
    for (verbListObject in verbList) {
      let verbScoreObject = {};
      verbScoreObject.conjugationScores = {};
      for (conjugation in verbListObject.conjugations) {
        verbScoreObject.conjugationScores[conjugation] = 0;
      }
      verbScoreObject.score = 0;
      verbScores2[verbListObject.name] = verbScoreObject;
    }
    return verbScores2;
  }
  function getKeyByValue(object, value) {
    return Object.keys(object).find((key) => object[key] === value);
  }
  var VERB_LIST = [
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
  function goToNextExcercise() {
    document.querySelector(".wordMatchingExcercise").style.display = "none";
    document.querySelector(".matchTheSentenceExcercise").style.display = "block";
  }
  function goToFirstExcercise() {
    document.querySelector(".wordMatchingExcercise").style.display = "block";
    document.querySelector(".matchTheSentenceExcercise").style.display = "none";
  }
  var verbScores = createScoresListFromVerbList(VERB_LIST);
  var selectedPronoun;
  var selectedConjugation;
  var previousScore2 = 0;
  var verb2 = VERB_LIST[Math.floor(Math.random() * VERB_LIST.length)];
  var first_excercise_default = {
    verb: verb2,
    getKeyByValue,
    createScoresListFromVerbList,
    goToFirstExcercise,
    goToNextExcercise,
    handleClickPronoun: handleClickPronoun2,
    previousScore: previousScore2,
    /*
     * generate the conjugation game html elements
     * @param _verb - the verb to generate the elements for
     */
    generateConjugationGameElements: function(_verb) {
      document.querySelector("h2.verblabel").innerHTML = verb2.name;
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
      for (let i = 0; i < Object.keys(_verb.conjugations).length; i++) {
        let conjugation2 = _verb.conjugations[Object.keys(_verb.conjugations)[i]];
        let keyName = getKeyByValue(_verb.conjugations, conjugation2);
        let element = document.querySelector("." + Object.keys(_verb.conjugations)[i] + "-conjugate");
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

  // script.js
  example();
  generateConjugationGameElements = first_excercise_default.generateConjugationGameElements;
  verb = first_excercise_default.verb;
  handleClickPronoun = first_excercise_default.handleClickPronoun;
  previousScore = first_excercise_default.previousScore;
  document.addEventListener("DOMContentLoaded", function(event) {
    for (pronoun in verb.conjugations) {
      let element = document.querySelector("." + pronoun + "-conjugate");
      element.innerHTML = verb.conjugations[pronoun];
    }
  });
})();
