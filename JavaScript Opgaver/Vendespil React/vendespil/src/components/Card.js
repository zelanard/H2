import { useContext, useState } from 'react';
import { UserContext } from '../App';

export default function Card(props) {
    const [picked, setPicked, newPick, setNewPick] = useContext(UserContext);
    const [face, setFace] = useState(false);

    const handleClick = () => {
        if (picked && newPick) {
            setPicked(props.id);
            setFace(true);
            setNewPick(null);
        }

        if (picked == null) {
            setPicked(props.id);
            setFace(true);

        } else if (newPick == null) {
            setNewPick(props.id);
            setFace(true);
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