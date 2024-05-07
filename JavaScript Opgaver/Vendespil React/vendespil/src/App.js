import React, { useEffect, useState } from 'react';
import Deck from './components/Deck';

/**
 * Create a Context for the user's current game state.
 * This context will hold state values and functions that manage the current state of the memory game.
 */
export const UserContext = React.createContext();

/**
 * The App component serves as the root component for the memory game application.
 * It provides a React context for the game state and renders the Deck component.
 *
 * @returns {JSX.Element} The App component with the Deck wrapped in a UserContext provider.
 */
function App() {
  const [picked, setPicked] = useState(null);
  const [newPick, setNewPick] = useState(null);
  const [resetCards, setResetCards] = useState(false);

  return (
    <div className="App" style={{
      display: "flex",
      flexWrap: "wrap",
      width: "800px"
    }}>
      <UserContext.Provider value={[picked, setPicked, newPick, setNewPick, resetCards, setResetCards]}>
        <Deck />
      </UserContext.Provider>
    </div>
  );
}

export default App;
