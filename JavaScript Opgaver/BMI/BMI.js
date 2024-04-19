//get the TrueBody div
const Body = document.getElementById("TrueBody");

//create all objects in the BMI calculator.
const strings = [
    {
        text: document.createTextNode("Welcome to the BMI calculator!"),
        element: document.createElement("h1")
    },
    {
        text: document.createTextNode("Insert your height and weight and press the button to calculate your BMI"),
        element: document.createElement("p"),
    },
    {
        text: document.createTextNode("Calcualte BMI"),
        element: document.createElement("button")
    },
    {
        text: document.createTextNode("Insert your height here"),
        element: document.createElement("input"),
        placeholder: "Height in Meters"
    },
    {
        text: document.createTextNode("Insert your weight here"),
        element: document.createElement("input"),
        placeholder: "weight in kg"
    },
    {
        text: document.createTextNode(""),
        element: document.createElement("p"),
        value: "Your bmi is: "
    }
];

//BMI categories
Category = [
    "Body Weight Deficit",
    "Norm",
    "Over Weight",
    "Obesity 1st degree",
    "Obesity 2nd degree",
    "Obesity 3rd degree",
];

//create the site
let i = 0;
strings.forEach((object) => {
    object.element.innerHTML = object.text.nodeValue;
    object.element.id = "Object_" + i;
    if (i == 2) {
        object.element.addEventListener("click", buttonClick);
    }
    if (object.placeholder) {
        object.element.placeholder = object.placeholder;
    }
    Body.appendChild(object.element);
    i++;
});

function buttonClick() {
    //Make the bmi calculatrion
    let height = parseFloat(document.getElementById("Object_3").value);
    let weight = parseFloat(document.getElementById("Object_4").value);
    let BMI = weight / (height * height);

    //write the result to the site
    let result = strings[5].value + BMI + "\n" + Category[BMIcategory(BMI)];
    document.getElementById("Object_5").innerHTML = result;
}

//Get the BMI index for the Category
function BMIcategory(bmi) {
    if (bmi < 18.5) return 0;
    if (bmi < 25) return 1;
    if (bmi < 30) return 2;
    if (bmi < 35) return 3;
    if (bmi < 40) return 4;
    return 5;
}