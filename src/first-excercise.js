

  /*
   * change the buttons of the matched element 
   */
  function showTheMatch(element) {
    document.querySelector(".cell.selected").classList.add("correct");
    document.querySelector(".cell.selected").innerHTML = selectedPronoun + " " + selectedConjugation;
    document.querySelector(".cell.selected").classList.remove("selected");

    element.classList.add("correct");
    element.innerHTML = selectedPronoun + " " + selectedConjugation;
  }


  /*
   * check if all the verb conjugations are matched
   */
  function allAreMatched() {
    return document.querySelectorAll(".cell.correct").length >= 12;
  }



  /*
   * set a new verb for the next problem
   */
  function getNextProblem() {
    let completedVerbs = []
    completedVerbs.push(verb.name);
    while (completedVerbs.includes(verb.name)) {
      verb = VERB_LIST[ Math.floor(Math.random() * VERB_LIST.length) ]
    }

    updatePreviousScoreElement();

    generateConjugationGameElements(verb);
  }


  /*
   * update the text for information on the last problem
   */
  function updatePreviousScoreElement() {
    document.querySelector("h2.previousScore").innerHTML = "You got " + previousScore + " wrong on the last problem";
  }


  /*
   * handle click event for conjugation buttons
   */
  function handleClickConjugation(event) {
    selectedConjugation = event.target.innerHTML;
    if (selectedPronoun != null) {
      if (verb.conjugations[selectedPronoun] == selectedConjugation) {
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

    const buttons = document.querySelectorAll('.cell');
    highlightOnlyOne(buttons, event.target);
    selectedConjugation = event.target.innerHTML;
  }


  /*
   * highlight only one button and remove highlight from all others
   * @param target - the button to highlight
   * @param buttons - the list of all buttons to remove highlight from
   */
  function highlightOnlyOne(buttons, target) {
    // Remove highlight class from all buttons
    buttons.forEach(button => {
        button.classList.remove('selected');
    });

    // Add highlight class to target
    target.classList.add('selected');
  }



  /*
   * show the temporary popup
   */
  function showPopup() {
      const popup = document.getElementById('popup');

      // Show the popup with fade-in effect
      popup.classList.add('show');

      // After 2 seconds, fade out the popup
      setTimeout(function() {
          popup.classList.remove('show');
      }, 2000); // 2000 ms = 2 seconds
  }


/*
 * handle click event for pronoun buttons
 */
function handleClickPronoun(event) {
  selectedPronoun = event.target.innerHTML.split("...")[0];
  if (selectedConjugation != null) {
    if (verb.conjugations[selectedPronoun] == selectedConjugation) {
      showTheMatch(event.target);
      if (allAreMatched()) {
        showPopup();
        getNextProblem();
        // TODO: make sentenceMatchingExcercise. this shows first. this is a one sentence per excercise. the conjugation score is determined from this. also verb and ending.
        // when the user gets this right, the next excercise is shown.
        // TODO: make fillInBlankExcercise. this shows second. this is a sentence with a blank verb. this effects conjugation score.  also verb and ending scores.
        // scoring: the total number wrong. compare to other categories (verb, conjugation, excercise)
            // when the total wrong for the conjugation is zero (ending, verb, conjugation same) is zero, the verb conjugation changes and the first excercise is shown. if the total wrong for all conjugations are each zero for the verb, the verb changes. and the first excercise is shown again. if the total wrong for all verbs is zero, the excercise changes to the word matching excercise. . 
          // for the word matching excercise, if the total wrong for all verbs is zero, the verb ending changes, along with the verb and conjugation, and the first excercise is shown again. if the total wrong for all endings is zero, a "congratulations, you won!" message is shown.

        // step 1. shows first problem
        // step 2. after completing, new score is calculated. then if the problem is 2 or more below the best score, the problem is shown again. if the problem is 1 below the best score, the next problem is shown.
        // but there is a score for the problem, the verb, and the verb ending. so there is a score associated with the actual problem, the score associated with the verb, and the score associated with the verb ending.
        // TODO: a data structure for this
        // TODO: an algorithm for this
        // TODO therefore, : level system is 001 is first excercise. 002 for other conjugations until 006. then when the verb changes and level 010. then at the word matching excercise the level is 100. when the verb ending changes, it becomes the first excercise again and goes to level 101. when the second ending gets to the word matching excercise, it beomes level 200. then when the third ending gets to the word matching excercise, it becomes level 600. then the conjugations and verbs go up until 666. then when the conjugation is all done, the user wins and level 777 is a fill in the blank for "the beast is preparing to leave his mark" and 777 is shown with a "congratulations, you won!" message.
        // TODO: level 000 is a tutorial that explains what the game is.
      }
      selectedConjugation = null;
      selectedPronoun = null;
      return;
    } else {
      previousScore += 1;
    }
  }

  const buttons = document.querySelectorAll('.cell');
  highlightOnlyOne(buttons, event.target);
  selectedPronoun = event.target.innerHTML.split('...')[0];
}



/*
 * create a scores list for each verb from a verb list in the format of VERB_LIST
 * @param verbList - the list of verbs to create the scores list from
 * @return the scores list
 */
function createScoresListFromVerbList(verbList) {
  let verbScores = {};
  for (verbListObject in verbList) {
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

let endingScores = {
  "ar": 0,
  "er": 0,
  "ir": 0
}

/*
 * get the key of an object by its value
 * @param object - the object to search
 * @param value - the value to search for
 * @return the key of the object
 */
function getKeyByValue(object, value) {
  return Object.keys(object).find(key => object[key] === value);
}

const VERB_LIST = [
  {
    name: "Tener",
    conjugations: {yo: "tengo",
      tu: "tienes",
      el: "tiene",
      nosotros: "tenemos",
      vosotros: "tenéis",
      ellos: "tienen"},
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



/* 
 * show the second excercise
 */
function goToNextExcercise() {
  document.querySelector('.wordMatchingExcercise').style.display = 'none';
  document.querySelector('.matchTheSentenceExcercise').style.display = 'block';
}


/*
 * show the first excercise
 */
function goToFirstExcercise() {
  document.querySelector('.wordMatchingExcercise').style.display = 'block';
  document.querySelector('.matchTheSentenceExcercise').style.display = 'none';
}

let verbScores = createScoresListFromVerbList(VERB_LIST);


let selectedPronoun;
let selectedConjugation;

let completedVerbs = []

var previousScore = 0;



let verb = VERB_LIST[ Math.floor(Math.random() * VERB_LIST.length) ]

export default {
  verb: verb,
  getKeyByValue: getKeyByValue,
  createScoresListFromVerbList: createScoresListFromVerbList,
  goToFirstExcercise: goToFirstExcercise,
  goToNextExcercise: goToNextExcercise,
  handleClickPronoun: handleClickPronoun,
  previousScore: previousScore,

/*
 * generate the conjugation game html elements
 * @param _verb - the verb to generate the elements for
 */

generateConjugationGameElements: function(_verb) {
    document.querySelector('h2.verblabel').innerHTML = verb.name;

    let conjugationElements = document.querySelectorAll("div.conjugation.section div.cell");
    if (conjugationElements.length > 0) {
      for (let i = 0; i<conjugationElements.length; i++) {
        conjugationElements[i].remove();
      }
    }
    let pronounElements = document.querySelectorAll("div.cell.correct");
    for (let i = 0; i<pronounElements.length; i++) {
      pronounElements[i].innerHTML = pronounElements[i].innerHTML.split(" ")[0];
      pronounElements[i].classList.remove("correct");
    }
    let elementList = []
    for (let i = 0; i < Object.keys(_verb.conjugations).length; i++) {
      let conjugation = _verb.conjugations[Object.keys(_verb.conjugations)[i]];
      let keyName = getKeyByValue(_verb.conjugations, conjugation);
      let element = document.querySelector("." + Object.keys(_verb.conjugations)[i] + "-conjugate");
      let cellElement = document.createElement('div');
      cellElement.classList.add('cell');
      cellElement.classList.add(keyName + '-conjugate');
      cellElement.classList.add('conjugate');
      cellElement.innerHTML = conjugation;
      cellElement.onclick = function(event) {
        handleClickConjugation(event);
      }
      elementList.push(cellElement);
    }
    const randomizedList = elementList.sort(() => Math.random() - 0.5);
    for (let element in randomizedList) {
      document.querySelector("div.conjugation.section").appendChild(randomizedList[element]);
    }
  }

}

