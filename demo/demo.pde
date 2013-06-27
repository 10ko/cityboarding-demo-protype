/*
* This is an example to show one of the possible application of the jtfl4processing library.
* It simulates the bus arrivals panel you can find at
* http://www.tfl.gov.uk/tfl/gettingaround/maps/buses/tfl-bus-map/text/stopinfo.aspx?s=183
* that shows the arrival information for the King's Cross Station Bus Stop.
*
* Author: Emanuele tenko Libralato
*
*/

import jtfl4processing.core.*;
import jtfl4processing.core.impl.bus.model.*;
import jtfl4processing.core.impl.bus.instant.*;
import java.util.*;
import processing.serial.*;
import cc.arduino.*;

Arduino arduino;

color off = color(4, 79, 111);
color on = color(84, 145, 158);

int[] values = { Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW,
 Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW,
 Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW };


PFont f;

JTFLBusAPI api = new BusStopInstantAPI();      // Initialize APIs
List<BusStopPrediction> predictionList;        // The List that will store the predictions
Calendar currentTime = Calendar.getInstance(); // We'll use it to make some date operations

String stopId = "18215";                         // The id of the King's Cross Station bus stop
int time;

color fillingBus = color(100,100,100);

void setup() {
  time = 0;
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  
  for (int i = 0; i <= 13; i++)
    arduino.pinMode(i, Arduino.OUTPUT);
  
  // Gets array of prediction for the bus stop
  // In this case I use a List to store the predictions but you can choose to use arrays too.
  predictionList = api.getBusStopPredictionList(stopId,"StopPointName","EstimatedTime","LineID","DestinationText");
  // Let's sort the list by arrival time.
  Collections.sort(predictionList);
  
  // We set up the window height based on the number of predictions
  int maxHeight = (predictionList.size()+2)*24;
  size(400,300);
  f = createFont("Courier",16,true);
  
}

void draw() {
 
  if( millis() > time ){
    time = millis() + 1000;
    predictionList = api.getBusStopPredictionList(stopId,"StopPointName","EstimatedTime","LineID","DestinationText");
    currentTime = Calendar.getInstance();
   /* List<BusStopPrediction> removeList = new ArrayList<BusStopPrediction>();
    for(BusStopPrediction pred : predictionList){
      if(!pred.getLineId().equals("205"))
        removeList.add(pred);
    }
    predictionList.removeAll(removeList);*/
  }

  background(0);
  textFont(f,12);
  fill(255,198,0);
  text("Route",50,20);
  textAlign(CENTER);
  text("Destination",width/2,20);
  text("Time",350,20);
  
  // We iterate the list and we print out the values we need.
  for(int i=0; i< predictionList.size(); i++){
    BusStopPrediction stopPred = predictionList.get(i);
    //if(stopPred.getLineId().equals("205")){
      // we retrieve the line id
      text(stopPred.getLineId(),50,20*(i+2));
      textAlign(CENTER);
      // the destination text
      text(stopPred.getDestinationText(),width/2,20*(i+2));
      // and we calculate how many minutes we still have to wait
      text(getMinutesOfWait(stopPred.getEstimatedTime()),350,20*(i+2));
    //}
    break;
  }
  
  int x=125,y=90;
  fill(fillingBus);
  beginShape();
  vertex(x+30, y+20);
  vertex(x+130, y+20);
  vertex(x+130, y+50);
  vertex(x+140, y+50);
  vertex(x+140, y+80);
  ellipse(x+110, y+80, 25, 25);
  ellipse(x+60, y+80, 25, 25);
  
  vertex(x+30, y+80);
  endShape(CLOSE);
  
}

// The function gets a date expressed in Unix Time (http://en.wikipedia.org/wiki/Unix_epoch)
// and it returns the difference between that and the current time, expressed in minutes.
int getMinutesOfWait(Long timeOfArrival){
  int res = (int)((timeOfArrival-currentTime.getTimeInMillis())/1000);
  if(res > 150){
    fillingBus = color(100,100,100);
    arduino.analogWrite(6, 0);
    arduino.analogWrite(3, 0);
  }else if(res <= 150 && res > 60){
    fillingBus = color(10,240,20);
    arduino.analogWrite(6, 0);
    arduino.analogWrite(3, 255);
  }else{ 
    fillingBus = color(240,20,0);
    arduino.analogWrite(6, 200);
    arduino.analogWrite(3, 0);
  } 
  
  return res;
}





