// This Sketch is getting data from the
// LIDAR Sensor Sensor Over OSC
// Connect the sensor and run "lidar-scanner-osc.py"
// To get data from the sensor and broadcast it over OSC
// Run this sketch to start listening to the broadcast and draw ripples

import controlP5.*;
import java.util.Iterator;
import oscP5.*;
import netP5.*;
import processing.video.*;

OscP5 oscP5;
NetAddress myBroadcastLocation; 

// use this to scale the dimetions coming down from the lidar (mm to pixels)
float scale = 1;
// used for live Mode make Area of interest full screen
float screenScaleX;
float screenScaleY;

// Area of interest coordinates
// For calibration place an object in the top left and bottom right corners
// Click the mouse where the objects appers and update the coordinates below:
// PVector tlCorner = new PVector(1340,620);
// PVector brCorner = new PVector(2518,1290);
PVector tlCorner = new PVector(700,520);
PVector brCorner = new PVector(1880,1200);
int minAngle = 90;
int maxAngle = 270;

// Bank of all he points detected by the LIDAR sensor, its center position
PVector[] points = new PVector[360];
PVector lidarPos;

// Ripples Particle system 
ParticleSystem ps;
PVector ps_origin;

// ###  Settings Sliders and Deafault Values setup ####
ControlP5 cp5;

// How many points define the ripple shape
int control_points = 24;

// How wiggly the shape will be
int max_radius = 100;
int min_radius = 90;

//how fast will the ripple grow/expand 
float growth = 1.8;

// Lifespan Max value is 255 if the particle to be fully opaque when it first appears
int life_span = 255; 

// how fast the particles fade
float fade_speed = 10;

// The width of the ripple shape stroke (if used)
int ripple_width = 7;    

//  Fill and stroke visibility
boolean shape_fill = false;
boolean shape_strtoke = true;

color stroke_color = color(255, 255, 255);
color fill_color = color(200, 200, 200);

// how often to create a new particle (Higher value is slower)
int freq = 4;

boolean is_live_mode = true;

// ###  End of Deafault Sliders Values ####

// UI Videos
int movieWidth = 640;
int movieHeight = 360;
int numMovies = 3;
Movie[] playlist = new Movie[numMovies]; 
int currentMovieIndex  = 0;
static final int PAYMENT = 6;
static final int INFOLINE = 7;
static final int INFOLINEDELAY = 8;

// SCENE SETUP
void setup() {
  // Set Canvas Size
  //size(1600,900);
  fullScreen();
  println(width, height);
  frameRate(30);

  // OSC Server Setup
  oscP5 = new OscP5(this,12000);
  //myBroadcastLocation = new NetAddress("127.0.0.1",12000);
  
  // create control panel
  cp5 = new ControlP5(this);
  drawSliders();

  // Define LIDAR Sensnsor position
  lidarPos = new PVector(width/2, height/8);   

  // Used to scale the Area of interest to full screen szie in "Live Mode"
  screenScaleX = width / (brCorner.x - tlCorner.x);
  screenScaleY = height / (brCorner.y - tlCorner.y);

  // Add new particle system
  ps_origin = new PVector(width/2, height/2); 
  ps = new ParticleSystem(ps_origin);
  
  // load UI videos
  playlist[0] = new Movie(this,"info-line.mov");
  playlist[1] = new Movie(this,"info-line.mov");
  playlist[2] = new Movie(this,"info-line.mov");
  playlist[currentMovieIndex].loop();
  
  background(0);
  stroke(255);
  strokeWeight(4);
  
}


// DRAW SCENE EVERY FRAME 
void draw() {
  background(0);  

  // update particle system position  
  // add new particle to the system every x frames 
  if (frameCount % freq == 0){
    stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
    fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
    ps.addParticle(control_points, max_radius, min_radius, growth, 
                    life_span, fade_speed, ripple_width, shape_fill, 
                    shape_strtoke, stroke_color, fill_color);
  }
  
  if (is_live_mode == true) {
    pushMatrix();
    scale(screenScaleX, screenScaleX);
    translate(-tlCorner.x, -tlCorner.y);
    visualizeLidarTracking();
    popMatrix();
  } else {
    visualizeLidarTracking();
  } 

}

void visualizeLidarTracking(){
  
  // an array to store all the points in the Area of interest for user postion estimation
  PVector[] interestPoints = new PVector[0];
  // user position
  PVector userPos = new PVector(0,0);
  
  // Draw area of interest
  stroke(120, 0, 0);
  rect(tlCorner.x , tlCorner.y, brCorner.x - tlCorner.x, brCorner.y - tlCorner.y);

  // Draw Lidar detection points data
  // Points inside the interest area are drawn brighter
  for (int i = minAngle; i < maxAngle; i++){
    if (points[i] != null){
      // check if the dot is within the area of interest 
      if (points[i].x > tlCorner.x && points[i].x < brCorner.x && points[i].y > tlCorner.y && points[i].y < brCorner.y) {
        stroke(255);
        point(points[i].x, points[i].y);
        interestPoints = (PVector[])append(interestPoints, points[i]);
      } else{
        stroke(80);
        point(points[i].x, points[i].y);
      }
    }
  }

  // Add tracker if a user was detected
  // And calculate the avarage position of all the points
  for (int i = 0; i < interestPoints.length; i++){
    if (interestPoints[i] != null){
      userPos.add(interestPoints[i]);
    }
  }
  userPos.x = userPos.x / interestPoints.length;
  userPos.y = userPos.y / interestPoints.length;
  
  // *** DRAW VIDEOS  ***
  // playlist[currentMovieIndex].loop();
   image(playlist[currentMovieIndex], userPos.x - movieWidth/2, userPos.y - movieHeight * 1.2, movieWidth, movieHeight);


  // *** DRAW RIPPLES ***
  //ps_origin.x = mouseX;
  //ps_origin.y = mouseY;
  ps_origin = userPos.copy();
  ps.origin = ps_origin.copy();
  // calculate and update all particle system elemets
  ps.run();


  // Draw green circle around the user (for testing)
  // stroke(0,255,0);
  // fill(0, 0, 0, 30);
  // ellipse(userPos.x, userPos.y, 280, 280);

}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {

  addPoint(theOscMessage.get(0).floatValue(), theOscMessage.get(1).floatValue());
  
  //char isNewScan = theOscMessage.typetag().charAt(2);
  // if(isNewScan == 'F'){
    // addPoint(theOscMessage.get(0).floatValue(), theOscMessage.get(1).floatValue());
  // }else{
  //   points = new PVector[0];
  // }
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //println(theOscMessage.get(0).floatValue() + " " + theOscMessage.get(1).floatValue()  + " " + theOscMessage.typetag());
  //println(theOscMessage.get(0).floatValue() + " " + theOscMessage.get(1).floatValue()  + " " + theOscMessage.get(2).floatValue());  

}

// Add a point coming from the lidar sensor to the points array 
void addPoint(float angle, float dist){
  int intAngle = int(angle);
  dist = dist / scale;
  if(angle < points.length){
    PVector new_point = new PVector(lidarPos.x + dist*sin(radians(angle)), lidarPos.y - dist*cos(radians(angle)) );
    points[intAngle] = new_point;
  }
  //println(angle, dist);
}

void mousePressed() {
  println(mouseX, mouseY);
}

void movieEvent(Movie m) {
    m.read();
}

void drawSliders(){
  
  cp5.addSlider("control_points")
    .setPosition(10,10)
    .setSize(100,15)
    .setRange(4,100)
    ;

  cp5.addSlider("min_radius")
    .setPosition(10,30)
    .setSize(100,15)
    .setRange(1,300)
    ;

  cp5.addSlider("max_radius")
    .setPosition(10,50)
    .setSize(100,15)
    .setRange(1,300)
    ;
  
  cp5.addSlider("growth")
    .setPosition(10,70)
    .setSize(100,15)
    .setRange(0,10)
    ;

  cp5.addSlider("life_span")
    .setPosition(10,90)
    .setSize(100,15)
    .setRange(1, 255)
    .setValue(255)
    ;

  cp5.addSlider("fade_speed")
    .setPosition(10,110)
    .setSize(100,15)
    .setRange(0,10)
    ;
  
  cp5.addSlider("ripple_width")
    .setPosition(10,130)
    .setSize(100,15)
    .setRange(0,50)
    ;

  cp5.addSlider("freq")
    .setPosition(10,150)
    .setSize(100,15)
    .setRange(1,100)
    ;    

  cp5.addToggle("shape_fill")
    .setPosition(10,170)
    .setSize(30,15)
    .setCaptionLabel("fill")
     ;
  cp5.addToggle("shape_strtoke")
    .setPosition(50,170)
    .setSize(30,15)
    .setCaptionLabel("stroke")
    ;

  cp5.addToggle("is_live_mode")
    .setPosition(90,170)
    .setSize(30,15)
    .setCaptionLabel("live")
    ;

  cp5.addColorWheel("strokeCol" , 10 , 220 , 120 )
    .setRGB(stroke_color)
    .setCaptionLabel("stroke_color")
    ;

  cp5.addColorWheel("fillCol" , 10 , 360 , 120 )
    .setRGB(fill_color)
    .setCaptionLabel("fill_color")
    ;

}
