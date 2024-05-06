import { useEffect, useState, useContext } from "react";
import Card from "./Card";
import { UserContext } from "../App";

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