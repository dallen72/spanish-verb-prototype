import type { Card } from './matching';

export const promptCard: Card = {
    text: "He speaks",
    value: "el-habla"
} as const;

export const answerCards: Card[] = [
    {
        text: "yo hablo",
        value: "yo-hablo"
    },
    {
        text: "tú hablas",
        value: "tu-hablas"
    },
    {
        text: "él habla",
        value: "el-habla"
    },
    {
        text: "nosotros hablamos",
        value: "nosotros-hablamos"
    },
    {
        text: "vosotros habláis",
        value: "vosotros-hablais"
    },
    {
        text: "ellos hablan",
        value: "ellos-hablan"
    }
]; 