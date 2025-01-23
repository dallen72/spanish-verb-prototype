interface Card {
    text: string;
    value: string;
    isActive: boolean;
    isMatched: boolean;
}

/**
 * Handles the logic when a card is clicked
 * @param {Card[]} cards - Array of all cards
 * @param {Card} clickedCard - The card that was just clicked
 * @returns {Card[]} Updated array of cards with new states
 */
export function handleCardClick(cards: Card[], clickedCard: Card): Card[] {
    // If card is already matched, do nothing
    if (clickedCard.isMatched) {
        return cards;
    }

    const activeCard = cards.find(card => card.isActive);
    
    if (clickedCard === activeCard) {
        return cards.map(card => ({...card, isActive: false}));
    } else if (!activeCard) {
        return cards.map(card => 
            card === clickedCard 
                ? {...card, isActive: true}
                : card
        );
        // TODO: value is not a good way to check for match. this looks like
        // they are the same card. change name to matchValue?
    } else if (activeCard.value === clickedCard.value) {
        return cards.map(card => 
            (card === activeCard || card === clickedCard)
                ? {...card, isMatched: true, isActive: false}
                : card
        );
    } else {
        return cards.map(card => ({...card, isActive: false}));
    }
} 
