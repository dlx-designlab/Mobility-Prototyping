
#include <Adafruit_TiCoServo.h>
#include <Adafruit_NeoPixel.h>
#include "Adafruit_VL53L0X.h"

// TOF Sensor
Adafruit_VL53L0X lox = Adafruit_VL53L0X();


Adafruit_TiCoServo  myservo;  // create servo object to control a servo
// twelve servo objects can be created on most boards
int servoPos = 50;    // variable to store the servo servoPosition


#define LED_PIN    6
#define LED_COUNT 50
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);
uint32_t color = strip.Color(255, 255, 255);

int currentPos = 0;
int newPos;
int colHue = int(65536/3);
int colSat = 100;
int ledStep = 1;


int servoMax = 50;
int servoMin = 80;


void setup() {

  Serial.begin(115200);

  // wait until serial port opens for native USB devices
  while (! Serial) {
    delay(1);
  }
  
  Serial.println("Adafruit VL53L0X test");
  if (!lox.begin()) {
    Serial.println(("Failed to boot VL53L0X"));
    while(1);
  }
  
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo.write(servoPos);  

  strip.begin();           // INITIALIZE NeoPixel strip object (REQUIRED)
  strip.show();            // Turn OFF all pixels ASAP
  strip.setBrightness(50); // Set BRIGHTNESS to about 1/5 (max = 255)
    
}

void loop() {

  color = strip.Color(255,   0,   0);
  
  VL53L0X_RangingMeasurementData_t measure;   
  Serial.print("Reading a measurement... ");
  lox.rangingTest(&measure, false); // pass in 'true' to get debug data printout!

  if (measure.RangeStatus != 4) {  // phase failures have incorrect data
  
    int range = measure.RangeMilliMeter;
    Serial.print("Distance (mm): "); Serial.println(range);

    if (range < 100)
    {      
      newPos = 9;
      colHue = 1;
      colSat = 255;
      teween_fade(colHue, colSat, 10, newPos, servoMax);
      currentPos = newPos;
    }    
    else
    {
      newPos = currentPos + ledStep;
      colHue = int(65536/3);
      colSat = 100;

      if (newPos > strip.numPixels() - 1)
        ledStep = -1;
      else if (newPos < 1)
        ledStep = 1;

      teween_fade(colHue, colSat, 10, newPos, servoMin);
      currentPos = newPos;
    }
    
  }

}


void teween_fade(int hue, int sat, int wait, int toPos, int shellPos){
  
  myservo.write(shellPos);

  int steps = toPos - currentPos;
  int step = 1;

  if (steps < 0)
    step = -1;

  // steps = abs(steps);
  int i = currentPos;

  while(i != toPos) 
  { 
    
    strip.clear();
    strip.setPixelColor(i, strip.ColorHSV(hue, sat, 127));
    
    for (int j = 1; j < int(strip.numPixels() / 3); j++)
    {
      if( i + j < strip.numPixels() )
        strip.setPixelColor( i + j, strip.ColorHSV(hue, sat, int(127 / j)) );
      else
        strip.setPixelColor( i + j - strip.numPixels() , strip.ColorHSV(hue, sat, int(127 / j)) );
      
      if( i - j >= 0 )
        strip.setPixelColor( i - j, strip.ColorHSV(hue, sat, int(127 / j)) );
      else
        strip.setPixelColor( i - j + strip.numPixels() , strip.ColorHSV(hue, sat, int(127 / j)) );

    } 

    i += step;
    
    strip.show();
    delay(wait);

  }

}
