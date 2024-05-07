import { useEffect, useState, useContext } from "react";
import Card from "./Card";
import { UserContext } from "../App";

/**
 * Deck component that handles the rendering and logic of the memory game's deck of cards.
 * It manages the state of the cards, shuffles them, and updates the game state based on interactions.
 *
 * @param {Object} props The props passed to the Deck component.
 * @returns {Array} An array of Card components representing the shuffled deck.
 */
export default function Deck(props) {
    const [picked, setPicked, newPick, setNewPick, resetCards, setResetCards] = useContext(UserContext);
    const [deckValues, setDeckValues] = useState([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    const [deck, setDeck] = useState(shuffle(displayDeck(deckValues)));

    useEffect(() => {
        if (picked && newPick) {
            let p = picked.indexOf("-");
            let n = newPick.indexOf("-");
            if (picked.substring(0, p) === newPick.substring(0, n)) {
                deck.forEach(element => {
                    if (element.props.id == picked) {
                        deck.splice(deck.indexOf(element), 1);
                    } else if (element.props.id == newPick) {
                        deck.splice(deck.indexOf(element), 1);
                    }
                });
            }
        }
    }, [picked, newPick]);

    return deck;
}

/**
 * Creates a visual representation of the deck using Card components.
 * Each card value is represented twice in the deck for matching purposes.
 *
 * @param {Array} deckValues Array containing unique values for the cards.
 * @returns {Array} An array of Card components.
 */
function displayDeck(deckValues) {
    let result = [];
    deckValues.map((value, index) => {
        result.push(<Card
            key={index + "-0"}
            id={index + "-0"}
            card={value}
        />)
        result.push(<Card
            key={index + "-1"}
            id={index + "-1"}
            card={value}
        />)
    });
    return result;
}

/**
 * Shuffles the elements of an array in place using the Fisher-Yates algorithm.
 *
 * @param {Array} array The array to shuffle.
 * @returns {Array} The shuffled array.
 */
function shuffle(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
}