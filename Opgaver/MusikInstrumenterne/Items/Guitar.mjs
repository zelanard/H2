import Stringed from "./Stringed.mjs";

/** Guitar models a guitar which is a Stringed Instrument
 */
export default class Guitar extends Stringed {
    material;
    constructor(numberOfStrings, material) {
        super(numberOfStrings, "Guitar");
        this.material = material;
    }

    /** Convert the Guitars properties to a string
     * 
     * @returns a sting containing information about the Guitar
     */
    ToString() {
        return `Your ${this.name} has ${this.numberOfStrings} strings and it is made from ${this.material}`;
    }
}