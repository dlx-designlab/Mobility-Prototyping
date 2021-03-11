import controlP5.*;
import java.util.*;
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
int freq = 30;

int scale_size = 100;

// TODO: change scale
// coordinate of the display heat
int heat_from_display_origin_x = 500;
int heat_from_display_origin_y = 100;

// ###  End of Deafault Sliders Values ####

ArrayList<Integer> max_grid_list = new ArrayList();

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
    
    
    if (frameCount % freq == 0) {
        max_grid_list.clear();
        // 1
        int back_right_count = 0;
        // 2
        int back_middle_count = 0;
        // 3
        int back_left_count = 0;
        // 4
        int front_right_count = 0;
        // 5
        int front_middle_count = 0;
        // 6 
        int front_left_count = 0;
        for (int x = 0; x < width; x +=10) {
            for (int y = 0; y < height; y +=10) {
                float d = camera.getDistance(x, y);
                if (d > 0.6 && d <= 0.8) {
                    if (x >= 0 && x < width / 3) {
                        back_right_count += 1;
                    }
                    if (x >= width / 3 && x < width / 3 * 2) {
                        back_middle_count += 1;
                    }
                    if (x >= width / 3 * 2 && x < width) {
                        back_left_count += 1;
                    }
                }
                if (d > 0.8 && d <= 1.0) {
                    if (x >= 0 && x < width / 3) {
                        front_right_count += 1;
                    }
                    if (x >= width / 3 && x < width / 3 * 2) {
                        front_middle_count +=1;
                    }
                    if (x >= width / 3 * 2 && x < width) {
                        front_left_count += 1;
                    }
                }
            }
        }
        
        max_grid_list.add(back_right_count);
        max_grid_list.add(back_middle_count);
        max_grid_list.add(back_left_count);
        max_grid_list.add(front_right_count);
        max_grid_list.add(front_middle_count);
        max_grid_list.add(front_left_count);
        
        int max_index = max_grid_list.indexOf(Collections.max(max_grid_list));
        println(max_index);
        
        //update particle system position
        switch(max_index) {
            case 0:
            ps_origin.x = 520;
            ps_origin.y = 360;
            break;
            case 1:
            ps_origin.x = 310;
            ps_origin.y = 360;
            break;
            case 2:
            ps_origin.x = 100;
            ps_origin.y = 360;
            break;
            case 3:
            ps_origin.x = 520;
            ps_origin.y = 120;
            break;
            case 4:
            ps_origin.x = 310;
            ps_origin.y = 120;
            break;
            case 5:
            ps_origin.x = 100;
            ps_origin.y = 120;
            break;
        }
        ps.origin = ps_origin.copy();
        println(ps.origin);
        addParticles(ps);
    }
    
    //calculate and update all particle system elemets
    ps.run();
    
    //Add a blur effect (might be slow on hight resolution canvas)//filter(BLUR, 2);
    
}

void addParticles(ParticleSystem ps) {
    stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
    fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
    ps.addParticle(control_points, max_radius, min_radius, growth, 
        life_span, fade_speed, ripple_width, shape_fill, 
        shape_strtoke, stroke_color, fill_color);
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
