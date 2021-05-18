import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.util.Iterator; 
import oscP5.*; 
import netP5.*; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class lidar_tracking_ripples extends PApplet {

// This Sketch is getting data from the
// LIDAR Sensor Over OSC
// To get data from the sensor and broadcast it over OSC
// connect the sensor and run "lidar-scanner-osc.py"
// Run this sketch to start listening to the broadcast and draw ripples







OscP5 oscP5;
Accordion accordion;

NetAddress myBroadcastLocation; 

// use this to scale the dimetions coming down from the lidar (mm to pixels)
float scale = 1;
// used for live Mode make Area of interest full screen
float screenScaleX;
float screenScaleY;

// Area of Interest (AOI) coordinates
// For calibration place an object in the top left and bottom right corners
// Click the mouse where the objects appers and update the coordinates below:
PVector tlCorner = new PVector(370,370);
PVector brCorner = new PVector(1555,1030);
// PVector tlCorner = new PVector(1340,620);
// PVector brCorner = new PVector(2518,1290);
// PVector tlCorner = new PVector(690,520);
// PVector brCorner = new PVector(1880,1200);
int minAngle = 90;
int maxAngle = 270;

// Bank of all he points detected by the LIDAR sensor, its center position
PVector[] points = new PVector[360];
PVector lidarPos;

PVector userPos = new PVector(0,0);
int userPosThreshold = 20;

//Particle systems
PVector ps_origin;
RippleParticleSystem ripplesPS;
RainParticleSystem rainPS;

// ###  Settings Sliders and Deafault Values setup ####
ControlP5 cp5;

// which scenario to play
int selectedScenario = 0;

// How many points define the ripple shape
int control_points = 24;

// How wiggly the shape will be
int max_radius = 100;
int min_radius = 90;

//how fast will the ripple grow/expand 
float growth = 1.8f;

// Lifespan Max value is 255 if the particle to be fully opaque when it first appears
int life_span = 255; 

// how fast the particles fade
float fade_speed = 10;

// The width of the ripple shape stroke (if used)
int ripple_width = 7;    

//  Fill and stroke visibility
boolean shape_fill = false;
boolean shape_strtoke = true;

int stroke_color = color(255, 255, 255);
int fill_color = color(200, 200, 200);

// how often to create a new particle (Higher value is slower)
int freq = 4;

boolean is_live_mode = true;
boolean show_aoi_frame = true;
boolean show_sensor_data = true;

// ###  End of Deafault Sliders Values ####

// UI Videos
int movieWidth = 800;
int movieHeight = 450;
int numMovies = 3;
Movie[] playlist = new Movie[numMovies]; 
int currentMovieIndex  = 0;

// SCENE SETUP
public void setup() {
  // Set Canvas Size
  // size(1600,900);
  
  println(width, height);
  frameRate(30);

  // OSC Server Setup
  oscP5 = new OscP5(this,12000);
  //myBroadcastLocation = new NetAddress("127.0.0.1",12000);
  
  // create control panel
  cp5 = new ControlP5(this);
  drawSliders();

  // Define LIDAR Sensnsor position
  lidarPos = new PVector(width/2, 20);   

  // Used to scale the Area of interest to full screen szie in "Live Mode"
  screenScaleX = width / (brCorner.x - tlCorner.x);
  screenScaleY = height / (brCorner.y - tlCorner.y);

  // Add new particle system
  ps_origin = new PVector(width/2, height/2); 
  ripplesPS = new RippleParticleSystem(ps_origin);
  rainPS = new RainParticleSystem(ps_origin);
  
  // load UI videos
  playlist[0] = new Movie(this,"info_line.mp4");
  playlist[1] = new Movie(this,"info_line_delay.mp4");
  playlist[2] = new Movie(this,"pay_remind_red.mp4");
  playlist[currentMovieIndex].loop();
    
}


// DRAW SCENE EVERY FRAME 
public void draw() {
  background(0);  
  
  if (is_live_mode) {
    pushMatrix();
    scale(screenScaleX, screenScaleX);
    translate(-tlCorner.x, -tlCorner.y);
    visualizeLidarTracking();
    popMatrix();
  } else {
    visualizeLidarTracking();
  } 

}

public void visualizeLidarTracking(){
  
  // an array to store all the points in the Area of interest for user postion estimation
  PVector[] interestPoints = new PVector[0];
  // user position
  PVector newUserPos = new PVector(0,0);
  
  // Draw area of interest frame
  if (show_aoi_frame){
    stroke(120, 0, 0);
    strokeWeight(2);
    noFill();
    rect(tlCorner.x , tlCorner.y, brCorner.x - tlCorner.x, brCorner.y - tlCorner.y);
  }

  // Draw Lidar detection points data
  // Points inside the interest area are drawn brighter and tracked
  if(show_sensor_data){
    strokeWeight(4); 
  }else{
    strokeWeight(0); 
  }
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
  if (interestPoints.length > 0){
    for (int i = 0; i < interestPoints.length; i++){
      if (interestPoints[i] != null){
        newUserPos.add(interestPoints[i]);
      }
    }
    newUserPos.x = newUserPos.x / interestPoints.length;
    newUserPos.y = newUserPos.y / interestPoints.length;    
  } else{
    newUserPos = new PVector(0,0);
  }

  // Update postion only if user moved enough
  // To prevent GUI poistion jitter
  if(userPos.dist(newUserPos) > userPosThreshold){
    userPos = newUserPos.copy();
  }

  // Display the selected scenario
  switch (selectedScenario) {
    // *** DRAW RIPPLES ***
    case(0):
      // update particle system position  
      // add new particle to the system every x frames 
      if (frameCount % freq == 0){
        stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
        fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
        ripplesPS.addParticle(control_points, max_radius, min_radius, growth, 
                        life_span, fade_speed, ripple_width, shape_fill, 
                        shape_strtoke, stroke_color, fill_color);
      }

      ripplesPS.origin = userPos.copy();
      ripplesPS.run();
      //ps_origin.x = mouseX;
      //ps_origin.y = mouseY;
      // ripplesPS.origin = ps_origin.copy();
      break;
    
    // *** DRAW RAIN ***
    case(1):
      // update particle system position  
      // add new particle to the system every x frames 
      if (frameCount % freq == 0){
        rainPS.addParticle(max_radius, min_radius, growth, 
                    life_span, fade_speed, ripple_width, shape_fill, 
                    shape_strtoke, stroke_color, fill_color);
      }

      int userBoxRad = 200;
      ps_origin.x = random(tlCorner.x, brCorner.x);
      ps_origin.y = random(tlCorner.y, brCorner.y);  
      while(ps_origin.x > userPos.x - userBoxRad && 
            ps_origin.x < userPos.x + userBoxRad &&
            ps_origin.y > userPos.y - userBoxRad &&
            ps_origin.y < userPos.y + userBoxRad){
        
        ps_origin.x = random(tlCorner.x, brCorner.x);
        ps_origin.y = random(tlCorner.y, brCorner.y);  
      }
      
      rainPS.origin = ps_origin.copy();
      rainPS.run();

      break;
    
    // *** DRAW INFO VIDEOS  ***
    case(2):
      currentMovieIndex = 0;
      drawVideo(1.2f);
      break;

    case(3):
      currentMovieIndex = 1;
      drawVideo(1.2f);
      break;
    
    case(4):
      currentMovieIndex = 2;
      drawVideo(0.5f);
      break;      

  }

  // Draw green circle around the user (for testing)
  // stroke(0,255,0);
  // fill(0, 0, 0, 30);
  // ellipse(userPos.x, userPos.y, 280, 280);  
}

public void drawVideo(float videoOffset){
      playlist[currentMovieIndex].loop();
      pushMatrix();
      translate(userPos.x + movieWidth/2, userPos.y + movieHeight * videoOffset);
      scale(-1,-1);
      image(playlist[currentMovieIndex], 0, 0, movieWidth, movieHeight);
      popMatrix();
}

/* incoming osc message are forwarded to the oscEvent method. */
public void oscEvent(OscMessage theOscMessage) {

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
public void addPoint(float angle, float dist){
  int intAngle = PApplet.parseInt(angle);
  dist = dist / scale;
  if(angle < points.length){
    PVector new_point = new PVector(lidarPos.x + dist*sin(radians(angle)), lidarPos.y - dist*cos(radians(angle)) );
    points[intAngle] = new_point;
  }
  //println(angle, dist);
}

public void mousePressed() {
  println(mouseX, mouseY);
}

public void movieEvent(Movie m) {
    m.read();
}

public void scenario_selector(int a) {
  selectedScenario = a;
  // println("a radio Button event: " + a + " / " + selectedScenario);
}

public void drawSliders(){

  Group g1 = cp5.addGroup("GUI Controls")
                .setBackgroundColor(color(20, 20, 20))
                .setBackgroundHeight(200)
                ;

  cp5.addToggle("is_live_mode")
    .setPosition(10,10)
    .setSize(35,15)
    .setCaptionLabel("LIVE")
    .moveTo(g1)
    ;

  cp5.addToggle("show_aoi_frame")
    .setPosition(55,10)
    .setSize(35,15)
    .setCaptionLabel("AoI")
    .moveTo(g1)
    ;

  cp5.addToggle("show_sensor_data")
    .setPosition(100,10)
    .setSize(35,15)
    .setCaptionLabel("SENSOR")
    .moveTo(g1)
    ;

  // Scenarios list
  cp5.addRadioButton("scenario_selector")
    .setPosition(10, 60)
    .setSize(20,20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(1)
    .setSpacingColumn(50)
    .addItem("Ripples",     0)
    .addItem("Ambient",     1)
    .addItem("Ride Info",   2)
    .addItem("Delay Info",  3)
    .addItem("Fare Remind", 4)        
    .activate(0)
    .moveTo(g1)
    ;


  Group g2 = cp5.addGroup("Ripples Control")
                .setBackgroundColor(color(20, 20, 20))
                .setBackgroundHeight(550)
                ;
          
  // particles parameters
  cp5.addSlider("control_points")
    .setPosition(10,10)
    .setSize(100,15)
    .setRange(4,100)
    .moveTo(g2)    
    ;

  cp5.addSlider("min_radius")
    .setPosition(10,30)
    .setSize(100,15)
    .setRange(1,300)
    .moveTo(g2)        
    ;

  cp5.addSlider("max_radius")
    .setPosition(10,50)
    .setSize(100,15)
    .setRange(1,300)
    .moveTo(g2)        
    ;
  
  cp5.addSlider("growth")
    .setPosition(10,70)
    .setSize(100,15)
    .setRange(0,10)
    .moveTo(g2)    
    ;

  cp5.addSlider("life_span")
    .setPosition(10,90)
    .setSize(100,15)
    .setRange(1, 255)
    .setValue(255)
    .moveTo(g2)    
    ;

  cp5.addSlider("fade_speed")
    .setPosition(10,110)
    .setSize(100,15)
    .setRange(0,10)
    .moveTo(g2)    
    ;
  
  cp5.addSlider("ripple_width")
    .setPosition(10,130)
    .setSize(100,15)
    .setRange(0,50)
    .moveTo(g2)    
    ;

  cp5.addSlider("freq")
    .setPosition(10,150)
    .setSize(100,15)
    .setRange(1,100)
    .moveTo(g2)    
    ;    

  cp5.addToggle("shape_fill")
    .setPosition(10,170)
    .setSize(30,15)
    .setCaptionLabel("fill")
    .moveTo(g2)    
    ;
  cp5.addToggle("shape_strtoke")
    .setPosition(50,170)
    .setSize(30,15)
    .setCaptionLabel("stroke")
    .moveTo(g2)    
    ;

  cp5.addColorWheel("strokeCol" , 10 , 220 , 120 )
    .setRGB(stroke_color)
    .setCaptionLabel("stroke_color")
    .moveTo(g2)    
    ;

  cp5.addColorWheel("fillCol" , 10 , 360 , 120 )
    .setRGB(fill_color)
    .setCaptionLabel("fill_color")
    .moveTo(g2)    
    ;

  // Construct theaccordion menu 
  accordion = cp5.addAccordion("acc")
                 .setPosition(10,10)
                 .setWidth(200)
                 .addItem(g1)
                 .addItem(g2)                 
                 ;
  
  // accordion.open(0,1,2);
  accordion.setCollapseMode(Accordion.MULTI);

}
// THE PARTICLE SYSYEM CALSS
class RainParticleSystem {
  ArrayList particles;
  PVector origin;

  // Constructor
  RainParticleSystem(PVector location) {
    origin = location.copy();
    particles = new ArrayList();
  }
 
  public void addParticle(int maxRad, int minRad, float growRate, 
                    int lifeSpan, float fadeSpeed, int rippleWidth, 
                    boolean shapeFill, boolean shapeStrtoke, int strokeColor, int fillColor) {
    particles.add(new RainParticle(origin, maxRad, minRad, growRate, lifeSpan, fadeSpeed, 
                                rippleWidth, shapeFill, shapeStrtoke, strokeColor, fillColor));
  }

  // Update all the particles in the system
  public void run() {
    Iterator<RainParticle> it = particles.iterator();
    while (it.hasNext()) {
      RainParticle p = it.next();
      p.run();
      if (p.isDead()) {
        it.remove();
      }
    }
  }
}


// INDIVIDUAL PARTICLE CLASS
class RainParticle {

  // PVector velocity;
  // PVector acceleration;
  // float size;
  PVector location; 
  float growth;
  float lifespan;
  float fadeSpeed;
  int rippleWidth;
  float rippleRadius;
  float angle;
  int minRad;
  int maxRad;
  float rippleRings[];
  boolean shapeFill;
  boolean shapeStrtoke;
  int fillCol;
  int strokeCol;
 
  // Coinstructor
  RainParticle(PVector l, int maxR, int minR, float growRate, 
                    int lifeSpan, float fadeSpd, int rippleW, 
                    boolean shpFill, boolean shpStrtoke, int strkColor, int fillColor) {
        
    // How wiggly the shape will be
    maxRad = maxR;
    minRad = minR;
    
    //how fast will the ripple grow/expand 
    growth = growRate;
    
    // Lifespan Max value is 255
    // If the particle to be fully opaque when it first appears
    lifespan = lifeSpan; 
    
    // how fast the particles fade
    fadeSpeed = fadeSpd;
    
    // The width of the ripple shape stroke (if used)
    rippleWidth = rippleW;    
    
    // The color of the fill / stroke (feel free to add more colors)
    strokeCol = strkColor;
    fillCol = fillColor;

    //  Fill and stroke visibility
    shapeFill = shpFill;
    shapeStrtoke = shpStrtoke;

    // Calculate the center of the ripple
    // And the angle between the shape points
    location = l.copy();


    // how many rings to show
    int numOfRings = 3;
    rippleRings = new float[numOfRings];

    // Fill the array of points which defines the ripple shape
    // Each array element is a random point-raduis, within the range: minRad <> maxRad
    rippleRadius = random(minRad, maxRad);
  }

  public void run() {
    update();
    display();
  }

  // Update RainParticle shape / position / size
  public void update() {
    // velocity.add(acceleration);
    // location.add(velocity);
    rippleRadius += growth;
    lifespan -= fadeSpeed;
  }
 
  // Draw the particle
  public void display() {

      // RainParticle style
      if(shapeFill)
        fill(fillCol, lifespan);
      else
        noFill();

      if(shapeStrtoke){
        stroke(strokeCol, lifespan);
        strokeWeight(rippleWidth);       
      } else
        noStroke();  

      ellipse(location.x, location.y, rippleRadius, rippleRadius);
  
  }

  // Check if particle reached end of life
  public boolean isDead() {
    if (lifespan < 0.0f) {
      return true;
    } else {
      return false;
    }
  }
}
// THE PARTICLE SYSYEM CALSS
class RippleParticleSystem {
  ArrayList particles;
  PVector origin;

  // Constructor
  RippleParticleSystem(PVector location) {
    origin = location.copy();
    particles = new ArrayList();
  }
 
  public void addParticle(int ctlPts, int maxRad, int minRad, float growRate, 
                    int lifeSpan, float fadeSpeed, int rippleWidth, 
                    boolean shapeFill, boolean shapeStrtoke, int strokeColor, int fillColor) {
    particles.add(new RippleParticle(origin, ctlPts, maxRad, minRad, growRate, lifeSpan, fadeSpeed, 
                                rippleWidth, shapeFill, shapeStrtoke, strokeColor, fillColor));
  }

  // Update all the particles in the system
  public void run() {
    Iterator<RippleParticle> it = particles.iterator();
    while (it.hasNext()) {
      RippleParticle p = it.next();
      p.run();
      if (p.isDead()) {
        it.remove();
      }
    }
  }
}


// INDIVIDUAL PARTICLE CLASS
class RippleParticle {

  // PVector velocity;
  // PVector acceleration;
  // float size;
  PVector location; 
  float growth;
  float lifespan;
  float fadeSpeed;
  int rippleWidth;
  float[] pointsRadius;
  float angle;
  int numOfPoints;
  int minRad;
  int maxRad;
  boolean shapeFill;
  boolean shapeStrtoke;
  int fillCol;
  int strokeCol;
 
  // Coinstructor
  RippleParticle(PVector l, int ctlPts, int maxR, int minR, float growRate, 
                    int lifeSpan, float fadeSpd, int rippleW, 
                    boolean shpFill, boolean shpStrtoke, int strkColor, int fillColor) {
    
    // How many points define the ripple shape
    numOfPoints = ctlPts;    
    
    // How wiggly the shape will be
    maxRad = maxR;
    minRad = minR;
    
    //how fast will the ripple grow/expand 
    growth = growRate;
    
    // Lifespan Max value is 255
    // If the particle to be fully opaque when it first appears
    lifespan = lifeSpan; 
    
    // how fast the particles fade
    fadeSpeed = fadeSpd;
    
    // The width of the ripple shape stroke (if used)
    rippleWidth = rippleW;    
    
    // The color of the fill / stroke (feel free to add more colors)
    strokeCol = strkColor;
    fillCol = fillColor;

    //  Fill and stroke visibility
    shapeFill = shpFill;
    shapeStrtoke = shpStrtoke;

    // Calculate the center of the ripple
    // And the angle between the shape points
    location = l.copy();
    angle = TWO_PI/(float)numOfPoints;

    // Fill the array of points which defines the ripple shape
    // Each array element is a random point-raduis, within the range: minRad <> maxRad
    pointsRadius = new float[numOfPoints];
    for(int i=0;i<numOfPoints;i++){
      pointsRadius[i] = random(minRad, maxRad);
    }


  }

  public void run() {
    update();
    display();
  }

  // Update RippleParticle shape / position / size
  public void update() {
    // velocity.add(acceleration);
    // location.add(velocity);
    for(int i=0;i<numOfPoints;i++)
    {
      pointsRadius[i] += growth;
    }
    lifespan -= fadeSpeed;
  }
 
  // Draw the particle
  public void display() {

    // RippleParticle style
    if(shapeFill)
      fill(fillCol, lifespan);
    else
      noFill();

    if(shapeStrtoke){
      stroke(strokeCol, lifespan);
      strokeWeight(rippleWidth);       
    } else
      noStroke();  

    // Draw a ripple shape
    beginShape();
    curveVertex(location.x + pointsRadius[numOfPoints-1]*sin(angle*(numOfPoints-1)), location.y + pointsRadius[numOfPoints-1]*cos(angle*(numOfPoints-1)));
    for(int i=0;i<numOfPoints;i++)
    {
      curveVertex(location.x + pointsRadius[i]*sin(angle*i), location.y + pointsRadius[i]*cos(angle*i));
    }
    curveVertex(location.x + pointsRadius[0]*sin(0), location.y + pointsRadius[0]*cos(0)); 
    curveVertex(location.x + pointsRadius[1]*sin(angle), location.y + pointsRadius[1]*cos(angle)); 
    endShape();
  
  }

  // Check if particle reached end of life
  public boolean isDead() {
    if (lifespan < 0.0f) {
      return true;
    } else {
      return false;
    }
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "lidar_tracking_ripples" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
