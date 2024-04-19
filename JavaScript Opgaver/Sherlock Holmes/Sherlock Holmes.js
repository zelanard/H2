var balance = 10500;
var cameraOn = true;


function steal(balance, amount) {
    cameraOn = false;
	
    //amount er større end than balance, så balance bliver aldrig sat.
    if (amount < balance) {
        balance = balance - amount;
    }
	
	//de returnerer den uændrede værdi
    return amount;
    
	//de tænder ikke for kameraet igen fordi denne linje ligger efter return.
    cameraOn = true;
}
var amount = steal(balance, 1250);

/** man kan ikke bryde en string midt i teksten.
 * "" + 
 * ""
*/ 
alert("Du er kriminel og du har lige stjålet " + amount + " og det må man
ikke!!!!")
