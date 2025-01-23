<script setup lang="ts">
import { ref } from 'vue';
import GameCard from './GameCard.vue';
import { handleCardClick } from '../lib/game/one-to-many-matching';
import { promptCard, answerCards } from '../lib/game/cardData';
import type { MatchingCard as CardType } from '../lib/game/one-to-many-matching';

const cards = ref<MatchingCard[]>([promptCard, ...answerCards]);

function onCardClick(clickedCard: CardType) {
    cards.value = handleCardClick(cards.value, clickedCard);
}
</script>

<template>
  <div class="exercise-container">
    <header>
      <p class="instructions">
        Match the English phrase with its correct Spanish conjugation. 
        Click a card to select it, then click its matching pair.
      </p>
    </header>

    <div class="game-container">
      <div class="prompt-side">
        <h2>Find the match:</h2>
        <GameCard 
          :text="cards[0].text"
          :value="cards[0].value"
          :is-active="cards[0].isActive"
          :is-matched="cards[0].isMatched"
          @click="onCardClick(cards[0])"
        />
      </div>
      
      <div class="answer-side">
        <h2>Available conjugations:</h2>
        <GameCard 
          v-for="(card, i) in answerCards"
          :key="i"
          :text="cards[i + 1].text"
          :value="cards[i + 1].value"
          :is-active="cards[i + 1].isActive"
          :is-matched="cards[i + 1].isMatched"
          @click="onCardClick(cards[i + 1])"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Import your existing CSS or include it here */
</style> 