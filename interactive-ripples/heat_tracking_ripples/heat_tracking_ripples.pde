import controlP5.*;
import java.util.*;
import ch.bildspur.realsense.*;
import ch.bildspur.realsense.type.*;

RealSenseCamera camera = new RealSenseCamera(this);


ControlP5 cp5;
ParticleSystem ps;
PVector ps_origin;

static final int RIPPLE = 0;
static final int ONBOARDING = 1;
static final int DRIVESTART = 2;
static final int DRIVESTOP = 3;

int drawMode = RIPPLE;

int camWidth = 848;
int camHeight = 480;

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
int freq = 30;

int scale_size = 100;

// ###  End of Deafault Sliders Values ####

ArrayList<Integer> max_grid_list = new ArrayList();

// SCENE SETUP
void setup() {
    //Set Canvas Size
    // size(640, 480);
    size(2544, 1440);
    camera.start();
    
    //enable depth stream
    camera.enableDepthStream(camWidth, camHeight);
    camera.addThresholdFilter(0.5,1.2);
    
    //enable colorizer to display depth
    // camera.enableColorizer(ColorScheme.Cold);
    
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
    
    //calculate and update all particle system elemets
    ps.run();
    
    switch(drawMode) {
        case(RIPPLE):
            freq = 60;
        if ((frameCount % freq == 0) || (frameCount % freq == 10) || (frameCount % freq == 15) || (frameCount % freq == 20)) {
            
            ps.origin = getGridPosition(ps_origin).copy();
            addParticles(ps);
        }
        //Add a blur effect (might be slow on hight resolution canvas)
        //filter(BLUR, 2);
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
    switch(key) {
        case('r') : drawMode = RIPPLE; break;
        case('o') : drawMode = ONBOARDING; break;
        case('s') : drawMode = DRIVESTART; break;
        case('p') : drawMode = DRIVESTOP; break;
    }
}

void addParticles(ParticleSystem ps) {
    stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
    fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
    ps.addParticle(control_points, max_radius, min_radius, growth, 
        life_span, fade_speed, ripple_width, shape_fill, 
        shape_strtoke, stroke_color, fill_color);
}

// logic for determining the grid position from the depth sensor input
PVector getGridPosition(PVector ps_origin) {
    max_grid_list.clear();
    
    int zone_0_count = 0;
    int zone_1_count = 0;
    int zone_2_count = 0;
    int zone_3_count = 0;
    int zone_4_count = 0;
    int zone_5_count = 0;
    
    for (int x = 0; x < width; x +=40) {
        for (int y = 0; y < height; y +=40) {
            float d = camera.getDistance(x/3, y/3);
            if (d > 0.6 && d <= 0.8) {
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
            if (d > 0.8 && d <= 1.2) {
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
    int num_of_pixel_threshold = 100;
    if (Collections.max(max_grid_list) < num_of_pixel_threshold) {
        max_index = 99;
    } else {
        max_index = max_grid_list.indexOf(Collections.max(max_grid_list));
    }
    println(max_index);
    println(max_grid_list);

    //update particle system position
    switch(max_index) {
        case 0:
        ps_origin.x = width / 6 * 5;
        ps_origin.y = height / 4;
        break;
        case 1:
        ps_origin.x = width / 2;
        ps_origin.y = height / 4;
        break;
        case 2:
        ps_origin.x = width / 6;
        ps_origin.y = height / 4;
        break;
        case 3:
        ps_origin.x = width / 6*5;
        ps_origin.y = height / 4 * 3;
        break;
        case 4:
        ps_origin.x = width / 2;
        ps_origin.y = height / 4 * 3;
        break;
        case 5:
        ps_origin.x = width / 6;
        ps_origin.y = height / 4 * 3;
        break;
        case 99:
        ps_origin.x = width *2;
        ps_origin.y = height * 2;
        break;
    }
    
    return ps_origin;
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
