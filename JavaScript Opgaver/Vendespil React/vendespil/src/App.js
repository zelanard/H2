import Card from './components/Card';
import React, { useState } from 'react';
import Deck from './components/Deck';

export const UserContext = React.createContext();

function App() {
  const [picked, setPicked] = useState(null);
  const [newPick, setNewPick] = useState(null);

  return (
    <div className="App" style={{
      display: "flex",
      flexWrap: "wrap",
      width: "800px"
    }}>
      <UserContext.Provider value={[picked, setPicked, newPick, setNewPick]}>
        <Deck />
      </UserContext.Provider>
    </div>
  );
}

export default App;