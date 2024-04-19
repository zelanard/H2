//get the TrueBody div
const Body = document.getElementById("TrueBody");

//Create the header
const header = document.createElement("H1");
const headerText = document.createTextNode("Welcome!");
header.appendChild(headerText);
Body.appendChild(header);

//create the button
const button = document.createElement("button");
button.addEventListener("click", buttonClick);

const buttonText = document.createElement("span");
buttonText.innerText = "Click me!";
button.appendChild(buttonText);
Body.appendChild(button);

//create the text
const display = document.createElement("p");
//display.classList.add("hidden");
const innerText = "Hello World!";
display.innerHTML = innerText;
Body.appendChild(display);

/** adds or removes the text content of the display element.
 * 
 */
function buttonClick() {
	/** this alternative method does not append the code
	 * intead it simply adds a class to it.
	 * in the css file you can see that this class contains "Display: None".
	 * this simply hides the element.
	 * 
	 * if (display.innerHTML == innerText) {
	 * 	display.innerHTML = "";
	 * } else {
	 * 	display.innerHTML = innerText;
	 * }
	 * 
	 * I would prefer this method, 
	 * if i want the user to easily see the elemetns in the html inspector.
	 */

	if (display.classList.contains("hidden")) {
		display.classList.remove("hidden");
	} else {
		display.classList.add("hidden");
	}
}