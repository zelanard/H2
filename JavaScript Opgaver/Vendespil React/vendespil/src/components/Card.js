import { useContext, useEffect, useState } from 'react';
import { UserContext } from '../App';

export default function Card(props) {
    const [picked, setPicked, newPick, setNewPick, resetCards, setResetCards] = useContext(UserContext);
    const [face, setFace] = useState(false);

    useEffect(() => {
        if (resetCards) {
            setFace(false);
            setResetCards(false);
            setNewPick(null);
            setPicked(null);
        }
    }, [resetCards, setResetCards]);

    const handleClick = () => {
        if (!face) {
            setFace(true);
            if (picked === null) {
                setPicked(props.id);
            } else if (newPick === null) {
                setNewPick(props.id);
                if (picked !== null && newPick !== null) {
                    // Set all cards to reset on next render
                    setResetCards(true);
                }
            } else if (picked && newPick) {
                setResetCards(true);
                setPicked(props.id);
                setNewPick(null);
            }
        }
    };

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