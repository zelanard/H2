import Instrument from "./Instrument.mjs";

/** Saxophone models a Saxophone which is an Intsrument
 */
export default class Saxophone extends Instrument{
    material;
    constructor(material) {
        super("Saxophone");
        this.material = material;
    }

    /** Convert the Saxophones properties to a string
     * 
     * @returns a sting containing information about the Saxophone
     */
    ToString() {
        return `Your ${this.name} is made from ${this.material}`;
    }
}