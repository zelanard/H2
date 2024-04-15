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
display.classList.add("hidden");
const text = document.createTextNode("Hello World");
display.appendChild(text);
Body.appendChild(display);


function buttonClick() {
	if (display.classList.contains("hidden")) {
		display.classList.remove("hidden");
	} else {
		display.classList.add("hidden");
	}
}