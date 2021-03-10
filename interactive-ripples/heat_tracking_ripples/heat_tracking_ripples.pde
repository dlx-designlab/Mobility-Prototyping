import controlP5.*;
import java.util.Iterator;
import ch.bildspur.realsense.*;
import ch.bildspur.realsense.type.*;

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

// ###  End of Deafault Sliders Values ####


// SCENE SETUP
void setup() {
    //Set Canvas Size
    size(640, 480);
    //frameRate(30);
    camera.start();
    
    //enable depth stream
    camera.enableDepthStream(width, height);
    camera.addThresholdFilter(0.5,1.2);
    
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
void draw() {
    background(0);  
    
    // read frames
    camera.readFrames();
    
    //update particle system position
    ps_origin.x = mouseX;
    ps_origin.y = mouseY;
    ps.origin = ps_origin.copy();
    
    if (frameCount % freq == 0) {
      int back_right_count = 0;
      int back_middle_count = 0;
      int back_left_count = 0;
      int front_right_count = 0;
      int front_middle_count = 0;
      int front_left_count = 0;
        for (int x = 0; x < width; x +=10) {
            for (int y = 0; y < height; y +=10) {
                float d = camera.getDistance(x, y);
                if (d > 0.6 && d <= 0.8) {
                    if (x >= 0 && x < width / 3) {
                        println("back","right");
                        back_right_count += 1;
                    }
                    if (x >= width / 3 && x < width / 3 * 2) {
                        println("back","middle");
                        back_middle_count += 1;
                    }
                    if (x >= width / 3 * 2 && x < width) {
                        println("back","left");
                        back_left_count += 1;
                    }
                }
                if (d > 0.8 && d <= 1.0) {
                    if (x >= 0 && x < width / 3) {
                        println("front","right");
                        front_right_count += 1;
                    }
                    if (x >= width / 3 && x < width / 3 * 2) {
                        println("front","middle");
                        front_middle_count +=1;
                    }
                    if (x >= width / 3 * 2 && x < width) {
                        println("front","left");
                        front_left_count += 1;
                    }
                }
            }
        }

        int [] max_grid_list = {back_right_count, back_middle_count, back_left_count, front_right_count, front_middle_count, front_left_count}
        int max_grid_value = max(max_grid_list);
    }
    
    //calculate and update all particle system elemets
    ps.run();
    
    //Add a blur effect (might be slow on hight resolution canvas)//filter(BLUR, 2);
    
}

void addParticles(ParticleSystem ps) {
    if (frameCount % freq == 0) {
        stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
        fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
        ps.addParticle(control_points, max_radius, min_radius, growth, 
            life_span, fade_speed, ripple_width, shape_fill, 
            shape_strtoke, stroke_color, fill_color);
    }
}

void drawSliders() {
    
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
