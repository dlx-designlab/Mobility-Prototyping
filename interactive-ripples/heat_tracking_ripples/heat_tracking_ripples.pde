
import controlP5.*;
import java.util.Iterator;

ControlP5 cp5;
ParticleSystem ps;
ShakeSystem ss;

PVector ps_origin;

static final int RIPPLE = 0;
static final int ONBOARDING = 1;
static final int DRIVESTART = 2;
static final int DRIVESTOP = 3;

int myDrawMode = RIPPLE;

// ###  Deafault Sliders Values ####
// How many points define the ripple shape
int control_points = 18;

// How wiggly the shape will be
int max_radius = 13;
int min_radius = 6;

//how fast will the ripple grow/expand 
float growth = 1.8;

// Lifespan Max value is 255 if the particle to be fully opaque when it first appears
int life_span = 300; 

// how fast the particles fade
float fade_speed = 60;

// The width of the ripple shape stroke (if used)
int ripple_width = 4;    

//  Fill and stroke visibility
boolean shape_fill = false;
boolean shape_strtoke = true;


color stroke_color = color(255, 255, 255);
color fill_color = color(200, 200, 200);

// how often to create a new particle (Higher value is slower)
int freq = 60;

// ###  End of Deafault Sliders Values ####


// SCENE SETUP
void setup() {
  // Set Canvas Size
  size(800, 800);
  frameRate(30);

  // control panel
  cp5 = new ControlP5(this);
  drawSliders();

  // Add new particle system
  ps_origin = new PVector(width/2, height/2); 
  ps = new ParticleSystem(ps_origin);
}


// DRAW SCENE EVERY FRAME 
void draw() {
    background(0);  

    // update particle system position
    ps_origin.x = mouseX;
    ps_origin.y = mouseY;
    ps.origin = ps_origin.copy();

    // calculate and update all particle system elemets
    ps.run();

    switch(myDrawMode) {
        case(RIPPLE):
            freq = 60;
            // add new particle to the system every x frames 
            if ((frameCount % freq == 0) || (frameCount % freq == 10) || (frameCount % freq == 15) || (frameCount % freq == 20)){
                 stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
                 fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
                 ps.addParticle(control_points, max_radius, min_radius, growth, 
                                 life_span, fade_speed, ripple_width, shape_fill, 
                                 shape_strtoke, stroke_color, fill_color);
                }
            break;
        case(ONBOARDING):
        break;
        case(DRIVESTART):
        break;
        case(DRIVESTOP):
        break;
    }
}

void keyPressed() {
  // check which key was pressed and set the
  // draw mode accordingly.
  switch(key) {
    case('r'): myDrawMode = RIPPLE; break;
    case('o'): myDrawMode = ONBOARDING; break;
    case('s'): myDrawMode = DRIVESTART; break;
    case('p'): myDrawMode = DRIVESTOP; break;
  }
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

  cp5.addColorWheel("strokeCol" , 10 , 220 , 120 )
    .setRGB(stroke_color)
    .setCaptionLabel("stroke_color")
    ;

  cp5.addColorWheel("fillCol" , 10 , 360 , 120 )
    .setRGB(fill_color)
    .setCaptionLabel("fill_color")
    ;

}
