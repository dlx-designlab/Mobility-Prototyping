import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.util.Iterator; 
import ch.bildspur.realsense.*; 
import ch.bildspur.realsense.type.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class heat_tracking_ripples extends PApplet {






RealSenseCamera camera = new RealSenseCamera(this);


ControlP5 cp5;
ParticleSystem ps;
PVector ps_origin;

// ###  Deafault Sliders Values ####
// How many points define the ripple shape
int control_points = 31;

// How wiggly the shape will be
int max_radius = 13;
int min_radius = 9;

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

// ###  End of Deafault Sliders Values ####


// SCENE SETUP
public void setup() {
    //Set Canvas Size
    
    //frameRate(30);
    camera.start();
    
    //enable depth stream
    camera.enableDepthStream(width, height);
    camera.addThresholdFilter(0.5f,1.2f);
    
    //enable colorizer to display depth
    camera.enableColorizer(ColorScheme.Cold);
    
    noCursor();
    
    
    //control panel
    cp5 = new ControlP5(this);
    drawSliders();
    
    //Add new particle system
    ps_origin = new PVector(width / 2, height / 2); 
    ps = new ParticleSystem(ps_origin);
}


// DRAW SCENE EVERY FRAME 
public void draw() {
    background(0);  
    
    // read frames
    camera.readFrames();
    
    //update particle system position
    ps_origin.x = mouseX;
    ps_origin.y = mouseY;
    ps.origin = ps_origin.copy();
    
    for (int x = 0; x < width; x +=10) {
        for (int y = 0; y < height; y +=10) {
            float d = camera.getDistance(x, y);
            if (d > 0.6f && d <= 0.8f) {
                if (x >= 0 && x < width / 3) {
                    println("back","right");
                }
                if (x >= width / 3 && x < width / 3 * 2) {
                    println("back","middle");
                }
                if (x >= width / 3 * 2 && x < width) {
                    println("back","left");
                }
            }
            if (d > 0.8f && d <= 1.0f) {
                if (x >= 0 && x < width / 3) {
                    println("front","right");
                }
                if (x >= width / 3 && x < width / 3 * 2) {
                    println("front","middle");
                }
                if (x >= width / 3 * 2 && x < width) {
                    println("front","left");
                }
            }
        }
    }
    
    //calculate and update all particle system elemets
    ps.run();
    
    //Add a blur effect (might be slow on hight resolution canvas)//filter(BLUR, 2);
      
}

public void addParticles(ParticleSystem ps) {
    if (frameCount % freq == 0) {
        stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
        fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
        ps.addParticle(control_points, max_radius, min_radius, growth, 
            life_span, fade_speed, ripple_width, shape_fill, 
            shape_strtoke, stroke_color, fill_color);
    }
}

public void drawSliders() {
    
    cp5.addSlider("control_points")
       .setPosition(10,10)
       .setSize(100,15)
       .setRange(4,100)
       ;
    
    cp5.addSlider("min_radius")
       .setPosition(10,30)
       .setSize(100,15)
       .setRange(1,100)
       ;
    
    cp5.addSlider("max_radius")
       .setPosition(10,50)
       .setSize(100,15)
       .setRange(1,100)
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
    
    cp5.addColorWheel("strokeCol" , 10 , 220 , 120)
       .setRGB(stroke_color)
       .setCaptionLabel("stroke_color")
       ;
    
    cp5.addColorWheel("fillCol" , 10 , 360 , 120)
       .setRGB(fill_color)
       .setCaptionLabel("fill_color")
       ;
    
}
// THE PARTICLE SYSYEM CALSS
class ParticleSystem {
  ArrayList particles;
  PVector origin;

  // Constructor
  ParticleSystem(PVector location) {
    origin = location.copy();
    particles = new ArrayList();
  }
 
  public void addParticle(int ctlPts, int maxRad, int minRad, float growRate, 
                    int lifeSpan, float fadeSpeed, int rippleWidth, 
                    boolean shapeFill, boolean shapeStrtoke, int strokeColor, int fillColor) {
    particles.add(new Particle(origin, ctlPts, maxRad, minRad, growRate, lifeSpan, fadeSpeed, 
                                rippleWidth, shapeFill, shapeStrtoke, strokeColor, fillColor));
  }

  // Update all the particles in the system
  public void run() {
    Iterator<Particle> it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      p.run();
      if (p.isDead()) {
        it.remove();
      }
    }
  }
}


// INDIVIDUAL PARTICLE CLASS
class Particle {

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
  Particle(PVector l, int ctlPts, int maxR, int minR, float growRate, 
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

  // Update Particle shape / position / size
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

    // Particle style
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
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "heat_tracking_ripples" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
