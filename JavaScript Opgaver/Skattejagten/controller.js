document.getElementById("map").addEventListener("load", findTheTreasure());
let youFoundTheTreasure = false;

/** Initializes the treasure finding game by setting 
 * up the treasure coordinates and click event listener on the map.
 */
function findTheTreasure() {
    let map = document.getElementById("map");
    let { x, y } = getRandomCoordiantes(); // Fetch random coordinates for the treasure
    let xMargin = map.clientWidth * 0.10;  // Margin for error in X direction
    let yMargin = map.clientHeight * 0.10; // Margin for error in Y direction
    let attempts = 0;

    // Add click event listener to the map
    document.getElementById("map").addEventListener("click", (event) => {
        ex = event.clientX;
        ey = event.clientY;
        click(ex, ey, x, y, xMargin, yMargin, attempts);
    });
}

/** Handles click events on the map and determines if the treasure has been found.
 * @param {number} eventX - The X coordinate of the mouse event.
 * @param {number} eventY - The Y coordinate of the mouse event.
 * @param {number} treasureX - The X coordinate of the treasure.
 * @param {number} treasureY - The Y coordinate of the treasure.
 * @param {number} xMargin - Allowed margin error in X direction.
 * @param {number} yMargin - Allowed margin error in Y direction.
 * @param {number} attempts - Current number of attempts made.
 * @param {boolean} showTreasure - Boolean indicating if the treasure is visible.
 */
function click(eventX, eventY, treasureX, treasureY, xMargin, yMargin, attempts) {
    let foundX = eventX >= treasureX - xMargin && eventX <= treasureX + xMargin;
    let foundY = eventY >= treasureY - yMargin && eventY <= treasureY + yMargin;

    if (foundX && foundY && !youFoundTheTreasure) {
        alert("You found the treasure!");
        insertFailX("green", treasureX, treasureY);
        youFoundTheTreasure = true;
        return;
    } else if (!youFoundTheTreasure) {
        youFoundTheTreasure = TreasureNotFound(attempts, treasureX, treasureY, foundX, foundY);
        attempts++;
    } else {
        let renew = confirm("Do you want to start a new game?");
        if (renew) {
            location.reload();
        }
    }
}

/** Provides feedback when the treasure is not found, and handles game over condition.
 * @param {number} attempts - Current number of attempts.
 * @param {number} treasureX - The X coordinate of the treasure.
 * @param {number} treasureY - The Y coordinate of the treasure.
 * @param {boolean} foundX - Boolean indicating if X coordinate was correct.
 * @param {boolean} foundY - Boolean indicating if Y coordinate was correct.
 * @returns {boolean} - Returns true if game is over, otherwise false.
 */
function TreasureNotFound(attempts, treasureX, treasureY, foundX, foundY) {
    let message = "";

    if (attempts >= 4) {
        alert("Game Over!");
        insertFailX("green", treasureX, treasureY);
        return true;
    } else {
        insertFailX();

        if (foundX) {
            message = "";
        } else if (ex < treasureX) {
            message = "Search further right";
        } else {
            message = "Search further left";
        }

        if (foundY) {
        } else if (ey < treasureY) {
            message += " & further down";
        } else {
            message += " & further up";
        }
    }
    alert(message);
    return false;
}

/**
 * Inserts an "X" image at a given location to mark a failed attempt.
 * @param {string} color - Color filter for the "X" image, default is "red".
 * @param {number} treasureX - X coordinate to place the "X".
 * @param {number} treasureY - Y coordinate to place the "X".
 */
function insertFailX(color = "red", treasureX = 0, treasureY = 0) {
    let fail = document.createElement("img");
    fail.classList.add("fail");
    fail.style.position = 'absolute';

    fail.style.zIndex = 1;
    fail.src = "./Resources/X.png";
    fail.width = 34;
    fail.height = 34;

    if (color != "red") {
        fail.style.filter = "hue-rotate(250deg)  brightness(150%)";
        fail.style.left = treasureX - 34 / 2 + 'px';
        fail.style.top = treasureY - 34 / 2 + 'px';
        fail.style.borderRadius = "100";
    } else {
        fail.style.left = ex - 34 / 2 + 'px';
        fail.style.top = ey - 34 / 2 + 'px';
    }
    document.body.appendChild(fail);
}

/**
 * Generates random coordinates within the dimensions of the map element.
 * @returns {Object} - An object containing X and Y coordinates.
 */
function getRandomCoordiantes() {
    let map = document.getElementById("map");
    x = Math.floor(Math.random() * map.clientWidth);
    y = Math.floor(Math.random() * map.clientHeight);
    return { x: x, y: y }
}
