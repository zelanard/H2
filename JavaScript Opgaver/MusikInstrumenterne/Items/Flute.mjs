import Instrument from "./Instrument.mjs";

/** Flute models a flute which is an instrument
 */
export default class Flute extends Instrument {
    constructor(holes, material) {
        super("Flute");
        this.holes = holes;
        this.material = material;
    }

    /** Convert the Flute properties to a string
     * 
     * @returns a sting containing information about the Flute
     */
    ToString() {
        return `Your ${this.name} has ${this.holes} holes and it is made from ${this.material}`;
    }
}