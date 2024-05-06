import { useEffect, useState, useContext } from "react";
import Card from "./Card";
import { UserContext } from "../App";

export default function Deck(props) {
    const [picked, setPicked, newPick, setNewPick, resetCards, setResetCards] = useContext(UserContext);
    const deckValues = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    useEffect(() => {
        if (picked == newPick) {
            deckValues.splice(deckValues.indexOf(picked), 1);
        }
    }, [picked]);


    const [deck, setDeck] = useState(shuffle(displayDeck(deckValues)));
    return deck;
}

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

function shuffle(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
}