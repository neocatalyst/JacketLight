import com.temboo.core.*;
import com.temboo.Library.Yahoo.Weather.*;
import processing.serial.*;

import cc.arduino.*;

Arduino arduino;

// Create a session using your Temboo account application details
TembooSession session = new TembooSession("neocatalyst", "myFirstApp", "62aa784f2aa74f11ae9c9709c3fd7823");

//Delare location array 
String location;
int currentLocation = 0;

// Declare fonts
PFont fontTemperature, fontLocation, fontInstructions;

// Give on-screen user instructions

// Set up some global values
int temperature;
XML weatherResults;

void setup() {
  size(350, 350);
  arduino = new Arduino(this, Arduino.list()[2], 57600);
    arduino.pinMode(13, Arduino.OUTPUT);

  // Set up fonts
  fontTemperature = createFont("Arial Black", 150);
  fontLocation = createFont("Arial Black", 36);
  fontInstructions = createFont("Arial Black", 16);
  fill(255); // Font color

  // Set up locations
  location = "Pittsburgh" ; // Total number of locations listed below

  // Display initial location
  runGetWeatherByAddressChoreo(); // Run the GetWeatherByAddress Choreo function
  getTemperatureFromXML(); // Get the temperature from the XML results
  displayColor(); // Set the background color
  displayText(); // Display text
}

void draw() {

    runGetWeatherByAddressChoreo(); // Run the GetWeatherByAddress Choreo function
    getTemperatureFromXML(); // Get the temperature from the XML results
    displayColor(); // Set the background color
    displayText(); // Display text
  }


void runGetWeatherByAddressChoreo() {
  // Create the Choreo object using your Temboo session
  GetWeatherByAddress getWeatherByAddressChoreo = new GetWeatherByAddress(session);

  // Set inputs
  getWeatherByAddressChoreo.setAddress(location);

  // Run the Choreo and store the results
  GetWeatherByAddressResultSet getWeatherByAddressResults = getWeatherByAddressChoreo.run();

  // Store results in an XML object
  weatherResults = parseXML(getWeatherByAddressResults.getResponse());
}

void getTemperatureFromXML() {
  // Narrow down to weather condition
  XML condition = weatherResults.getChild("channel/item/yweather:condition");

  // Get the current temperature in Fahrenheit from the weather conditions
  temperature = condition.getInt("temp");
  if(temperature<35){
        arduino.digitalWrite(13, Arduino.HIGH);
  }
else{
          arduino.digitalWrite(13, Arduino.LOW);

}
  // Print temperature value
  println("The current temperature in "+location+" is "+temperature+"ºF");
}

void displayColor() {
  // Set up the temperature range in Fahrenheit
  int minTemp = 10;
  int maxTemp = 95;

  // Convert temperature to a 0-255 color value
  float temperatureColor = map(temperature, minTemp, maxTemp, 0, 255);    

  // Set background color using temperature on a blue to red scale     
  background(color(temperatureColor, 0, 255-temperatureColor));
}

void displayText() {
  // Set up text margins
  int margin = 35;
  int marginTopTemperature = 150;
  int marginTopLocation = 175;

  // Display temperature
  textFont(fontTemperature);
  text(temperature, margin, marginTopTemperature);

  // Display location
  textFont(fontLocation);
  text(location, margin, marginTopLocation, width-margin, height-margin);


}
