<script lang="ts">
    import Card from '$lib/components/Card.svelte';
    import { handleCardClick } from '$lib/game/matching';
    import { promptCard, answerCards } from '$lib/game/cardData';
    import type { Card as CardType } from '$lib/game/matching';
    import './card-matching.css';
    
    let cards: CardType[] = [promptCard, ...answerCards];

    function onCardClick(clickedCard: CardType) {
        cards = handleCardClick(cards, clickedCard);
    }
</script>

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
            <Card 
                text={cards[0].text}
                value={cards[0].value}
                isActive={cards[0].isActive}
                isMatched={cards[0].isMatched}
                on:click={() => onCardClick(cards[0])}
            />
        </div>
        
        <div class="answer-side">
            <h2>Available conjugations:</h2>
            {#each answerCards as card, i}
                <Card 
                    text={cards[i + 1].text}
                    value={cards[i + 1].value}
                    isActive={cards[i + 1].isActive}
                    isMatched={cards[i + 1].isMatched}
                    on:click={() => onCardClick(cards[i + 1])}
                />
            {/each}
        </div>
    </div>
</div> 