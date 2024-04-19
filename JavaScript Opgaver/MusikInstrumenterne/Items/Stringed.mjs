import Instrument from "./Instrument.mjs";

/** Stringed models a stringed instrument
 */
export default class Stringed extends Instrument {
    numberOfStrings;
    constructor(numberOfStrings, name) {
        super(name);
        this.numberOfStrings = numberOfStrings;
    }
}