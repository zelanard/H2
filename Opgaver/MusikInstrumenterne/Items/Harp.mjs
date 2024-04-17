import Stringed from "./Stringed.mjs";

/** Harp models a harp which is a Stringed Instrument
 */
export default class Harp extends Stringed {
    height;
    constructor(numberOfStrings, height) {
        super(numberOfStrings, "Harp");
        this.height = height;
    }

    /** Convert the Harp properties to a string
     * 
     * @returns a sting containing information about the Harp
     */
    ToString() {
        return `Your ${this.name} has ${this.numberOfStrings} strings and it is ${this.material}cm tall`;
    }
}