import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.util.*; 
import ch.bildspur.realsense.*; 
import ch.bildspur.realsense.type.*; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class heat_tracking_ripples extends PApplet {






Movie paymentMovie;

RealSenseCamera camera = new RealSenseCamera(this);


ControlP5 cp5;
ParticleSystem ps;
ShakeSystem ss; 

PVector ps_origin;
PVector ss_origin;
PVector movie_origin;

int currentGridIndex = 99;

static final int RIPPLE = 0;
static final int ONBOARDING = 1;
static final int DRIVESTART = 2;
static final int DRIVESTOP = 3;
static final int RAIN = 4;

int numMovies = 3;
Movie[] playlist = new Movie[numMovies]; 
int currentMovieIndex  = 0;
static final int PAYMENT = 5;
static final int INFOLINE = 6;
static final int INFOLINEDELAY = 7;


int drawMode = RIPPLE;

// check supported config here
// https://github.com/cansik/realsense-processing
int camWidth = 848;
int camHeight = 480;

int movieWidth = 848;
int movieHeight = 477;

// ###  Default Sliders Values ####
// How many points define the ripple shape
int control_points = 31;

// How wiggly the shape will be
int max_radius = 55;
int min_radius = 50;

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
int freq = 30;

int scale_size = 100;

int radiusRate = 3;
// ###  End of Deafault Sliders Values ####

ArrayList<Integer> max_grid_list = new ArrayList();

// SCENE SETUP
public void setup() {
    
    camera.start();
    
    //enable depth stream
    camera.enableDepthStream(camWidth, camHeight);
    camera.addThresholdFilter(0.5f,1.2f);
    
    // noCursor();
    
    //control panel
    cp5 = new ControlP5(this);
    drawSliders();
    
    //Add new particle system
    ps_origin = new PVector(width*10, height*10); 
    ps = new ParticleSystem(ps_origin);
    
    
    // Add new shake system
    ss_origin = new PVector(width*10, height*10); 
    ss = new ShakeSystem(ss_origin);
    
    playlist[0] = new Movie(this,"payment-reminder_1.mov");
    playlist[1] = new Movie(this,"info-line.mov");
    playlist[2] = new Movie(this,"info-line-super-delay.mov");
    playlist[currentMovieIndex].loop();
}


// DRAW SCENE EVERY FRAME
public void draw() {
    background(0);
    
    // read frames
    camera.readFrames();
    
    
    switch(drawMode) {
        case(RIPPLE):
            ps.run();
            ps.origin.x = mouseX;
            ps.origin.y = mouseY;
            if (frameCount % freq == 0) {
                addParticles(ps);
            }
            break;
        
        case(ONBOARDING):
            ps.run();
            freq = 60;
            if (frameCount % freq == 0) {
                currentGridIndex = getGridIndex(ps_origin);
                ps.origin = getGridPosition(currentGridIndex).copy();
                addParticles(ps);
            }
            if (frameCount % freq == 20) {
                addParticles(ps);
            }
            if (frameCount % freq == 25) {
                addParticles(ps);
            }
            if (frameCount % freq == 30) {
                addParticles(ps);
            }
            break;

        case(DRIVESTART):
            ss.run();
            freq = 60;
            growth = 0.0f;
            // TODO: fade param needed
            if (frameCount % freq == 3) {
                currentGridIndex = getGridIndex(ss_origin);
                ss.origin = getGridPosition(currentGridIndex).copy();
                addShakes(ss, 60, 65);
                addShakes(ss, 50, 55);
                addShakes(ss, 40, 45);
                addShakes(ss, 30, 35);
                addShakes(ss, 20, 25);
            }
            break;

        case(DRIVESTOP):
            ss.run();
            freq = 60;
            growth = 0.0f;
            if (frameCount % freq == 3) {
                currentGridIndex = getGridIndex(ss_origin);
                ss.origin = getGridPosition(currentGridIndex).copy();
                addShakes(ss, 60, 65);
            }
            if (frameCount % freq == 6) {
                addShakes(ss, 50, 55);
            }
            if (frameCount % freq == 9) {
                addShakes(ss, 40, 45);
            }
            if (frameCount % freq == 12) {
                addShakes(ss, 30, 35);
            }
            if (frameCount % freq == 15) {
                addShakes(ss, 20, 25);
            }
            break;

        case(RAIN):
            ps.run();
            currentGridIndex = getGridIndex(ps_origin);
            switch(currentGridIndex){
                case 0:
                    if (frameCount % freq == 0) {
                        for(int i=0; i<100; i++){ 
                            int x = (int)random(width); 
                            ps.origin.x = x;
                            if (x > width*2/3) {
                                int y = (int)random(height/2, height);
                                ps.origin.y = y;
                            } else {
                                int y = (int)random(height);
                                ps.origin.y = y;
                            }
                            addParticles(ps);
                        }
                    }
                    break;
                case 1:
                    if (frameCount % freq == 0) {
                        for(int i=0; i<100; i++){ 
                            int x = (int)random(width); 
                            ps.origin.x = x;
                            if (x < width*2/3 && x > width/3) {
                                int y = (int)random(height/2, height);
                                ps.origin.y = y;
                            } else {
                                int y = (int)random(height);
                                ps.origin.y = y;
                            }
                            addParticles(ps);
                        }
                    }
                    break;
                case 2:
                    if (frameCount % freq == 0) {
                        for(int i=0; i<100; i++){ 
                            int x = (int)random(width); 
                            ps.origin.x = x;
                            if (x < width/3) {
                                int y = (int)random(height/2, height);
                                ps.origin.y = y;
                            } else {
                                int y = (int)random(height);
                                ps.origin.y = y;
                            }
                            addParticles(ps);
                        }
                    }
                    break;
                case 3:
                    if (frameCount % freq == 0) {
                        for(int i=0; i<100; i++){ 
                            int x = (int)random(width); 
                            ps.origin.x = x;
                            if (x > width*2/3) {
                                int y = (int)random(0, height/2);
                                ps.origin.y = y;
                            } else {
                                int y = (int)random(height);
                                ps.origin.y = y;
                            }
                            addParticles(ps);
                        }
                    }
                    break;

                case 4:
                    if (frameCount % freq == 0) {
                        for(int i=0; i<100; i++){ 
                            int x = (int)random(width); 
                            ps.origin.x = x;
                            if (x < width*2/3 && x > width/3) {
                                int y = (int)random(0, height/2);
                                ps.origin.y = y;
                            } else {
                                int y = (int)random(height);
                                ps.origin.y = y;
                            }
                            addParticles(ps);
                        }
                    }
                    break;

                case 5:
                    if (frameCount % freq == 0) {
                        for(int i=0; i<100; i++){ 
                            int x = (int)random(width); 
                            ps.origin.x = x;
                            if (x < width/3) {
                                int y = (int)random(0, height/2);
                                ps.origin.y = y;
                            } else {
                                int y = (int)random(height);
                                ps.origin.y = y;
                            }
                            addParticles(ps);
                        }
                    }
                    break;
            }
            break;

        case(PAYMENT):
            if (playlist!= null) {
                playlist[currentMovieIndex].stop();
                currentMovieIndex = 0;
                currentGridIndex = getGridIndex(ps_origin);
                movie_origin = getGridPosition(currentGridIndex).copy();
                playlist[currentMovieIndex].loop();
                image(playlist[currentMovieIndex], movie_origin.x - movieWidth / 2, movie_origin.y - movieHeight / 2, movieWidth, movieHeight);
            }
            break;
        case(INFOLINE):
            if (playlist!= null) {
                playlist[currentMovieIndex].stop();
                currentMovieIndex = 1;
                currentGridIndex = getGridIndex(ps_origin);
                movie_origin = getGridPosition(currentGridIndex).copy();
                playlist[currentMovieIndex].loop();
                image(playlist[currentMovieIndex], movie_origin.x - movieWidth / 2, movie_origin.y - movieHeight / 2, movieWidth, movieHeight);
            }
            break;
        case(INFOLINEDELAY):
            if (playlist!= null) {
                playlist[currentMovieIndex].stop();
                currentMovieIndex = 2;
                currentGridIndex = getGridIndex(ps_origin);
                movie_origin = getGridPosition(currentGridIndex).copy();
                playlist[currentMovieIndex].loop();
                image(playlist[currentMovieIndex], movie_origin.x - movieWidth / 2, movie_origin.y - movieHeight / 2, movieWidth, movieHeight);
            }
            break;
    }
}

public void movieEvent(Movie m) {
    m.read();
}

public void keyPressed() {
    switch(key) {
        case('e') : drawMode = RIPPLE; break;
        case('o') : drawMode = ONBOARDING; break;
        // TODO:
        case('s') : drawMode = DRIVESTART; break;
        case('p') : drawMode = DRIVESTOP; break;
        // TOOO:
        case('r') : drawMode = RAIN; break;
        // movies
        case('0') : drawMode = PAYMENT; break;
        case('1') : drawMode = INFOLINE; break;
        case('2') : drawMode = INFOLINEDELAY; break;
    }
}

public void addParticles(ParticleSystem ps) {
    stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
    fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
    ps.addParticle(control_points, max_radius, min_radius, growth, 
        life_span, fade_speed, ripple_width, shape_fill, 
        shape_strtoke, stroke_color, fill_color);
}

public void addShakes(ShakeSystem ss, int min_radius, int max_radius) {
    stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
    fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB(); 
    ss.addShake(control_points, max_radius, min_radius, growth, 
        life_span, fade_speed, ripple_width, shape_fill, 
        shape_strtoke, stroke_color, fill_color, radiusRate);
}

// logic for determining the grid position from the depth sensor input
public int getGridIndex(PVector vector_origin) {
    max_grid_list.clear();
    
    int zone_0_count = 0;
    int zone_1_count = 0;
    int zone_2_count = 0;
    int zone_3_count = 0;
    int zone_4_count = 0;
    int zone_5_count = 0;
    
    // Step has direct impact to performance. Change according to canvas size.
    int step = 40;
    for (int x = 0; x < width; x +=step) {
        for (int y = 0; y < height; y +=step) {
            float d = camera.getDistance(x / 3, y / 3);
            if (d > 0.5f && d <= 0.8f) {
                if (x >= 0 && x < width / 3) {
                    zone_0_count += 1;
                }
                if (x >= width / 3 && x < width / 3 * 2) {
                    zone_1_count += 1;
                }
                if (x >= width / 3 * 2 && x < width) {
                    zone_2_count += 1;
                }
            }
            if (d > 0.8f && d <= 1.2f) {
                if (x >= 0 && x < width / 3) {
                    zone_3_count += 1;
                }
                if (x >= width / 3 && x < width / 3 * 2) {
                    zone_4_count += 1;
                }
                if (x >= width / 3 * 2 && x < width) {
                    zone_5_count += 1;
                }
            }
        }
    }
    
    max_grid_list.add(zone_0_count);
    max_grid_list.add(zone_1_count);
    max_grid_list.add(zone_2_count);
    max_grid_list.add(zone_3_count);
    max_grid_list.add(zone_4_count);
    max_grid_list.add(zone_5_count);
    
    int max_index = 99;
    int num_of_pixel_threshold = 80;
    if (Collections.max(max_grid_list) < num_of_pixel_threshold) {
        max_index = 99;
    } else {
        max_index = max_grid_list.indexOf(Collections.max(max_grid_list));
    }
    println(max_grid_list);
    return max_index;
}

public PVector getGridPosition(int max_index) {
    PVector vector_origin = new PVector(width*10, height*10); 
    
    //update particle system position
    switch(max_index) {
        case 0:
        vector_origin.x = width / 6 * 5;
        vector_origin.y = height / 4;
        break;
        case 1:
        vector_origin.x = width / 2;
        vector_origin.y = height / 4;
        break;
        case 2:
        vector_origin.x = width / 6;
        vector_origin.y = height / 4;
        break;
        case 3:
        vector_origin.x = width / 6 * 5;
        vector_origin.y = height / 4 * 3;
        break;
        case 4:
        vector_origin.x = width / 2;
        vector_origin.y = height / 4 * 3;
        break;
        case 5:
        vector_origin.x = width / 6;
        vector_origin.y = height / 4 * 3;
        break;
        // case not to display on screen
        case 99:
        vector_origin.x = width * 10;
        vector_origin.y = height * 10;
        break;
    }
    
    return vector_origin;
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
       .setRange(1, 300)
       .setValue(300)
       ;
    
    cp5.addSlider("fade_speed")
       .setPosition(10,110)
       .setSize(100,15)
       .setRange(0,60)
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
    
    //Constructor
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
    
    //Update all the particles in the system
    public void run() {
        Iterator<Particle> it = particles.iterator();
        while(it.hasNext()) {
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
    
    //Coinstructor
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
        angle = TWO_PI / (float)numOfPoints;
        
        // Fill the array of points which defines the ripple shape
        // Each array element is a random point-raduis, within the range: minRad <> maxRad
        pointsRadius = new float[numOfPoints];
        for (int i = 0;i < numOfPoints;i++) {
            pointsRadius[i] = random(minRad, maxRad);
        }
    }
    
    public void run() {
        update();
        display();
    }
    
    //Update Particle shape / position / size
    public void update() {
        // velocity.add(acceleration);
        // location.add(velocity);
        for (int i = 0;i < numOfPoints;i++)
        {
            pointsRadius[i] += growth;
        }
        lifespan -= fadeSpeed;
    }
    
    //Draw the particle
    public void display() {
        
        // Particle style
        if (shapeFill)
            fill(fillCol, lifespan);
        else
            noFill();
        
        if (shapeStrtoke) {
            stroke(strokeCol, lifespan);
            strokeWeight(rippleWidth);       
        } else
            noStroke();  
        
        // Draw a ripple shape
        beginShape();
        curveVertex(location.x + pointsRadius[numOfPoints - 1] * sin(angle * (numOfPoints - 1)), location.y + pointsRadius[numOfPoints - 1] * cos(angle * (numOfPoints - 1)));
        for (int i = 0;i < numOfPoints;i++)
        {
            curveVertex(location.x + pointsRadius[i] * sin(angle * i), location.y + pointsRadius[i] * cos(angle * i));
        }
        curveVertex(location.x + pointsRadius[0] * sin(0), location.y + pointsRadius[0] * cos(0)); 
        curveVertex(location.x + pointsRadius[1] * sin(angle), location.y + pointsRadius[1] * cos(angle)); 
        endShape();
        
    }
    
    //Check if particle reached end of life
    public boolean isDead() {
        if (lifespan < 0.0f) {
            return true;
        } else {
            return false;
        }
    }
}
// THE SHAKE SYSYEM CALSS
class ShakeSystem {
  ArrayList shakes;
  PVector origin;

  // Constructor
  ShakeSystem(PVector location) {
    origin = location.copy();
    shakes = new ArrayList();
  }
 
  public void addShake(int ctlPts, int maxRad, int minRad, float growRate, 
                    int lifeSpan, float fadeSpeed, int rippleWidth, 
                    boolean shapeFill, boolean shapeStrtoke, int strokeColor, int fillColor, int radiusRate) {
    shakes.add(new Shake(origin, ctlPts, maxRad, minRad, growRate, lifeSpan, fadeSpeed,
                                rippleWidth, shapeFill, shapeStrtoke, strokeColor, fillColor, radiusRate));
  }

  // Update all the arcs in the system
  public void run() {
    Iterator<Shake> it = shakes.iterator();
    while (it.hasNext()) {
      Shake s = it.next();
      s.run();
      if (s.isDead()) {
        it.remove();
      }
    }
  }
}


// INDIVIDUAL PARTICLE CLASS
class Shake {

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
  int radiusRate;
 
  // Coinstructor
  Shake(PVector l, int ctlPts, int maxR, int minR, float growRate, 
                    int lifeSpan, float fadeSpd, int rippleW, 
                    boolean shpFill, boolean shpStrtoke, int strkColor, int fillColor, int radiusR) {
    
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
    
    // how fast the arcs fade
    fadeSpeed = fadeSpd;

    // The width of the ripple shape stroke (if used)
    rippleWidth = rippleW;    
    
    // The color of the fill / stroke (feel free to add more colors)
    strokeCol = strkColor;
    fillCol = fillColor;

    //  Fill and stroke visibility
    shapeFill = shpFill;
    shapeStrtoke = shpStrtoke;

    radiusRate = radiusR;

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

    // Draw arc
    beginShape();
    curveVertex(location.x + pointsRadius[numOfPoints-1]*cos(angle*(numOfPoints-1))*radiusRate, location.y - pointsRadius[numOfPoints-1]*sin(angle*(numOfPoints-1))*radiusRate);
    for(int i=0;i<numOfPoints;i++)
    {
      curveVertex(location.x + pointsRadius[i]*cos(angle*i)*radiusRate, location.y - pointsRadius[i]*sin(angle*i)*radiusRate);
    }
    curveVertex(location.x + pointsRadius[0]*cos(0)*radiusRate, location.y - pointsRadius[0]*sin(0)*radiusRate); 
    // curveVertex(location.x + pointsRadius[1]*cos(angle), location.y - pointsRadius[1]*sin(angle)); 
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
  public void settings() {  size(2544, 1440); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "heat_tracking_ripples" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
