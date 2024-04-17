import Flute from '../Items/Flute.mjs';
import Guitar from '../Items/Guitar.mjs';
import Harp from '../Items/Harp.mjs';
import Instrument from '../Items/Instrument.mjs';
import Saxophone from '../Items/Saxophone.mjs';

/** An array of all the Instruments we want to play.
*/
const someInstruments = [
    new Flute(9, "Wood"),
    new Saxophone("Brass"),
    new Harp(18, 25),
    new Guitar(6, "Oak")
];

/** Create each of the Instruments
 * 
 * @param {Instrument} Instrument from which the element is created
 */
function createObject(Instrument) {
    // The instrument is created in a <p> element
    let p = document.createElement("p");

    // We want the instrument to have a title
    let pText = document.createElement("h3");
    pText.innerText = Instrument.name;
    p.appendChild(pText);

    // Create the play button.
    let playButton = document.createElement("button");
    playButton.classList.add("playButton"); //add playButton to the class list - we use that to be able to stop it later.
    playButton.innerText = "Play"; //give it it's default text.

    // Add the function to be run when the button is clicked.
    playButton.addEventListener("click", () => {
        PlayHandler(playButton, Instrument);
    });
    p.appendChild(playButton);

    //show button
    let showButton = document.createElement("button");
    showButton.innerText = "Show";
    showButton.addEventListener("click", () => {
        ShowInstrumentHandler(Instrument, p);
    });
    p.appendChild(showButton);

    document.body.appendChild(p);
}

/** Control whether the instrument should be shown or not.
 * 
 * @param {Instrument} Instrument to be shown or hidden
 * @param {Element} p the Instruments paragraph
 */
function ShowInstrumentHandler(Instrument, p) {
    const id = Instrument.name + "_show";
    if (document.getElementById(id)) {
        document.getElementById(id).remove();
    } else {
        let val = document.createElement("div");
        val.id = id;
        val.innerText = Instrument.ToString();
        p.appendChild(val);
    }
}

/** Controls whether the instrument should play or stop 
 * 
 * @param {Element} playButton which have been pressed
 * @param {Instrument} Instrument which is to be controlled 
 */
function PlayHandler(playButton, Instrument) {
    if (playButton.innerText == "Play") {
        Stop();
        playButton.innerText = "Stop";
    } else {
        playButton.innerText = "Play";
    }
    Instrument.controlSound(playButton.innerText == "Stop");
}

/** Change the inner text of all playButtons to Play, 
 * thus indicating that they are not playing. 
*/
function Stop() {
    Array.from(document.getElementsByClassName("playButton")).forEach((element) => {
        element.innerText = "Play";
    })
}

// create the site
someInstruments.forEach((Instrument) => {
    createObject(Instrument);
});