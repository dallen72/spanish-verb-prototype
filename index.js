(() => {
  // src/main.js
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
  var verbScores = createScoresListFromVerbList(VERB_LIST);
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
  var verb = VERB_LIST[Math.floor(Math.random() * VERB_LIST.length)];
  document.addEventListener("DOMContentLoaded", function(event) {
    for (pronoun in verb.conjugations) {
      let element = document.querySelector("." + pronoun + "-conjugate");
      element.innerHTML = verb.conjugations[pronoun];
    }
  });
})();
