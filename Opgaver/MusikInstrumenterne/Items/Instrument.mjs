/** Instrument models an instrument
 */
export default class Instrument {
    name;
    constructor(name) {
        this.name = name;
    }

    /** Stop the sound
     */
    stopSound() {
        try {
            //get all audio elements (there be 0 or 1)
            const audios = document.getElementsByTagName('audio');

            //remove all audio elements
            if (typeof (audios) != "undefined") {
                Array.from(audios).forEach(audio => {
                    audio.remove();
                });
            }

        } catch (error) {
            console.error('Failed to remove audio elements:', error);
        }
    }

    /** Start the sound
     */
    playSound() {
        this.stopSound();
        let music = document.createElement('audio');
        music.src = "../resources/" + this.name + ".mp3";
        document.body.appendChild(music);
        music.play();
    }

    /** start or stop the sound
     * 
     * @param {Boolean} play 
     */
    controlSound(play){
        if (play) {
            this.playSound();
        } else {
            this.stopSound();
        }
    }
}