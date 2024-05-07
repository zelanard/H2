import { useContext, useEffect, useState } from 'react';
import { UserContext } from '../App';

/**
 * Card component represents a single card in the memory game.
 * It manages the card state such as whether it's face up or down.
 *
 * @param {Object} props The props object containing the card ID and other configurations.
 * @returns {JSX.Element} The card element as a clickable div that displays either the card face or back based on its state.
 */
export default function Card(props) {
    const [picked, setPicked, newPick, setNewPick, resetCards, setResetCards] = useContext(UserContext);
    const [face, setFace] = useState(false);

    useEffect(() => {
        handleReset();
    }, [resetCards, setResetCards]);

    /**
     * Handles the click event on the card.
     * Toggles the card face visibility and handles the game logic for card comparison and reset.
     */
    const handleClick = () => {
        if (!face) {
            handleReset().then(handleTurnCard());
            setFace(true);
        }
    };

    /**
     * Handles the card turn logic. Determines if the card should show its face based on the game's current state,
     * and updates the context state for picked and newPick.
     */
    const handleTurnCard = () => {
        if (picked === null) {
            setPicked(props.id);
        } else if (newPick === null) {
            setNewPick(props.id);
            if (picked !== null && newPick !== null) {
                setResetCards(true);
            }
        }
    }

    /**
     * Resets the card's face to hidden when invoked, typically after two cards have been turned and need to be reset.
     * Also manages resetting context states for the game logic.
     */
    const handleReset = async () => {
        if (picked && newPick) {
            setResetCards(true);
            setPicked(props.id);
            setNewPick(null);
        } else if (resetCards) {
            setFace(false);
            setResetCards(false);
            setNewPick(null);
            setPicked(null);
        }
    }

    return (
        <div style={{
            border: "3px solid black",
            padding: "15",
            backColur: "Green",
            width: "100px",
            height: "100px",
            borderRadius: "15px",
            margin: "10px",
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            fontSize: "50px"
        }}
            id={props.id}
            onClick={handleClick}
        >
            {face ? props.card : <img src='logo192.png' height={90} />}
        </div>
    )
}