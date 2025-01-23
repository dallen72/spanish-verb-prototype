import { describe, it, expect } from 'vitest';
import { handleCardClick } from './matching';
import type { Card } from './matching';

describe('handleCardClick', () => {
    // Card indices for better readability
    const PROMPT_CARD = 0;
    const MATCHING_CARD = 1;
    const NON_MATCHING_CARD = 2;

    // Helper function to create a fresh set of cards
    function createTestCards(): Card[] {
        return [
            { text: "He speaks", value: "he-speaks", isActive: false, isMatched: false },
            { text: "habla", value: "he-speaks", isActive: false, isMatched: false },  // Matches PROMPT_CARD
            { text: "hablas", value: "you-speak", isActive: false, isMatched: false }  // Different value
        ];
    }

    // Helper to activate a specific card
    function activateCard(cards: Card[], index: number): Card[] {
        return cards.map((card, i) => 
            i === index ? { ...card, isActive: true } : card
        );
    }

    // Helper to check if all cards are inactive
    function areAllCardsInactive(cards: Card[]): boolean {
        return cards.every(card => !card.isActive);
    }

    // Helper to check if specific cards are matched
    function areCardsMatched(cards: Card[], indices: number[]): boolean {
        return indices.every(index => cards[index].isMatched);
    }

    describe('when clicking a card', () => {
        it('should do nothing if clicked card is already matched', () => {
            const cards = createTestCards();
            const matchedCard: Card = { ...cards[PROMPT_CARD], isMatched: true };
            const result = handleCardClick(cards, matchedCard);
            
            expect(result).toEqual(cards);
        });

        it('should activate the first clicked card', () => {
            const cards = createTestCards();
            const result = handleCardClick(cards, cards[PROMPT_CARD]);
            
            expect(result[PROMPT_CARD].isActive).toBe(true);
            expect(areAllCardsInactive(result.filter((_, i) => i !== PROMPT_CARD))).toBe(true);
        });

        describe('when prompt card is active', () => {
            it('should mark matching cards as matched', () => {
                const cards = activateCard(createTestCards(), PROMPT_CARD);
                const result = handleCardClick(cards, cards[MATCHING_CARD]);
                
                expect(areCardsMatched(result, [PROMPT_CARD, MATCHING_CARD])).toBe(true);
                expect(areAllCardsInactive(result)).toBe(true);
            });

            it('should deactivate all cards when no match is found', () => {
                const cards = activateCard(createTestCards(), PROMPT_CARD);
                const result = handleCardClick(cards, cards[NON_MATCHING_CARD]);
                
                expect(areAllCardsInactive(result)).toBe(true);
                expect(areCardsMatched(result, [])).toBe(true);
            });

            it('should deactivate when clicking the same card again', () => {
                const cards = activateCard(createTestCards(), PROMPT_CARD);
                const result = handleCardClick(cards, cards[PROMPT_CARD]);
                
                expect(areAllCardsInactive(result)).toBe(true);
            });
        });

        describe('when matching card is active', () => {
            it('should mark matching cards as matched when prompt card is clicked', () => {
                const cards = activateCard(createTestCards(), MATCHING_CARD);
                const result = handleCardClick(cards, cards[PROMPT_CARD]);
                
                expect(areCardsMatched(result, [PROMPT_CARD, MATCHING_CARD])).toBe(true);
                expect(areAllCardsInactive(result)).toBe(true);
            });

            it('should deactivate when clicking the same card again', () => {
                const cards = activateCard(createTestCards(), MATCHING_CARD);
                const result = handleCardClick(cards, cards[MATCHING_CARD]);
                
                expect(areAllCardsInactive(result)).toBe(true);
            });

            it('should deactivate all cards when non-matching card is clicked', () => {
                const cards = activateCard(createTestCards(), MATCHING_CARD);
                const result = handleCardClick(cards, cards[NON_MATCHING_CARD]);
                
                expect(areAllCardsInactive(result)).toBe(true);
                expect(areCardsMatched(result, [])).toBe(true);
            });
        });
    });
}); 