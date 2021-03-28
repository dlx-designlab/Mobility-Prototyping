import controlP5.*;
import java.util.*;
import ch.bildspur.realsense.*;
import ch.bildspur.realsense.type.*;
import processing.video.*;
OpenSimplexNoise noise;

RealSenseCamera camera = new RealSenseCamera(this);


ControlP5 cp5;
ParticleSystem ps;
ParticleSystem _ps_2;
ShakeSystem ss;

PVector ps_origin;
PVector _ps_origin_2;
PVector ss_origin;
PVector movie_origin;
int rain_num = 10;
float [][] _ps_origin_list = new float[rain_num][2];
float [][] _ps_origin_list_2 = new float[rain_num][2];
int [] _radius_list = new int[rain_num];
int [] _radius_list_2 = new int[rain_num];

int currentGridIndex = 99;

static final int RIPPLE = 0;
static final int ONBOARDING = 1;
static final int DRIVESTART = 2;
static final int DRIVESTOP = 3;
static final int RAIN = 4;
static final int HEATWAVE = 5;

int numMovies = 3;
Movie[] playlist = new Movie[numMovies]; 
int currentMovieIndex  = 0;
static final int PAYMENT = 6;
static final int INFOLINE = 7;
static final int INFOLINEDELAY = 8;


int drawMode = ONBOARDING;

// check supported config here
// https://github.com/cansik/realsense-processing
int camWidth = 848;
int camHeight = 480;

int movieWidth = 1440;
int movieHeight = 765;

// ###  Default Sliders Values ####
// How many points define the ripple shape
int control_points = 31;

// How wiggly the shape will be
int max_radius = 55;
int min_radius = 50;

float circle_size = 0.5f;

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

int radiusRate = 3;

// ###  End of Deafault Sliders Values ####

ArrayList<Integer> max_grid_list = new ArrayList();

// SCENE SETUP
void setup() {
    // size(3816, 2160);
    // size(4240, 2400);
    fullScreen();
    surface.setSize(4240,2400);
    // surface.setSize(2544, 1440);
    // surface.setSize(1000, 1000);
    camera.start();
    
    //enable depth stream
    camera.enableDepthStream(camWidth, camHeight);
    camera.addThresholdFilter(0.5,1.2);
    
    noCursor();
    
    //control panel
    cp5 = new ControlP5(this);
    drawSliders();
    
    //Add new particle system
    ps_origin = new PVector(width*10, height*10); 
    _ps_origin_2 = new PVector(width*10, height*10); 
    ps = new ParticleSystem(ps_origin);
    _ps_2 = new ParticleSystem(_ps_origin_2);
    
    
    // Add new shake system
    ss_origin = new PVector(width*10, height*10); 
    ss = new ShakeSystem(ss_origin);
    
    playlist[0] = new Movie(this,"payment-reminder_1.mov");
    playlist[1] = new Movie(this,"info-line.mov");
    playlist[2] = new Movie(this,"info-line-super-delay.mov");
    playlist[currentMovieIndex].loop();

    // noise = new OpenSimplexNoise(12345); 
    noise = new OpenSimplexNoise(20000); 
}


// DRAW SCENE EVERY FRAME
void draw() {
    background(0);
    println(frameRate);
    
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
            ss.run();
            freq = 30;
            circle_size = 1.0f;
            int first_circle_size = 50;
            if (frameCount % freq == 0) {
                currentGridIndex = getGridIndex(ss_origin);
                ss.origin = getGridPosition(currentGridIndex).copy();
                addShakes(ss, first_circle_size, first_circle_size);
            }
            if (frameCount % freq == 10) {
                addShakes(ss, first_circle_size*2, first_circle_size*2);
            }
            if (frameCount % freq == 15) {
                addShakes(ss, first_circle_size*2, first_circle_size*2);
            }
            if (frameCount % freq == 20) {
                addShakes(ss, first_circle_size*2, first_circle_size*2);
            }
            break;

        case(DRIVESTART):
            ss.run();
            freq = 60;
            growth = 0.0;
            circle_size = 0.5f;
            int drive_start_circle_radius = 60;
            // TODO: fade param needed
            if (frameCount % freq == 3) {
                currentGridIndex = getGridIndex(ss_origin);
                ss.origin = getGridPosition(currentGridIndex).copy();
                addShakes(ss, drive_start_circle_radius, drive_start_circle_radius+5);
            }
            if (frameCount % freq == 6) {
                addShakes(ss, drive_start_circle_radius+10, drive_start_circle_radius+15);
            }
            if (frameCount % freq == 9) {
                addShakes(ss, drive_start_circle_radius+20, drive_start_circle_radius+25);
            }
            if (frameCount % freq == 12) {
                addShakes(ss, drive_start_circle_radius+30, drive_start_circle_radius+35);
            }
            if (frameCount % freq == 15) {
                addShakes(ss, drive_start_circle_radius+40, drive_start_circle_radius+45);
            }
            break;

        case(DRIVESTOP):
            ss.run();
            freq = 60;
            growth = 0.0;
            circle_size = 1.0f;
            int drive_stop_circle_radius = 105;
            if (frameCount % freq == 3) {
                currentGridIndex = getGridIndex(ss_origin);
                ss.origin = getGridPosition(currentGridIndex).copy();
                addShakes(ss, drive_stop_circle_radius, drive_stop_circle_radius+5);
            }
            if (frameCount % freq == 6) {
                addShakes(ss, drive_stop_circle_radius-10, drive_stop_circle_radius-5);
                drive_stop_circle_radius -= 10;
            }
            if (frameCount % freq == 9) {
                addShakes(ss, drive_stop_circle_radius-20, drive_stop_circle_radius-15);
            }
            if (frameCount % freq == 12) {
                addShakes(ss, drive_stop_circle_radius-30, drive_stop_circle_radius-25);
            }
            if (frameCount % freq == 15) {
                addShakes(ss, drive_stop_circle_radius-40, drive_stop_circle_radius-35);
            }
            break;

        case(RAIN):
            drawRain(0, ps_origin, ps, _ps_origin_list, _radius_list, rain_num);
            // drawRain(2);
            drawRain(4, _ps_origin_2, _ps_2, _ps_origin_list_2, _radius_list_2, rain_num);
            // drawRain(6);
            // drawRain(8);
            break;

        case(HEATWAVE):
            int numFrames = 10;
            float t = 1.0*frameCount/numFrames;
            // int m = 450;
            int width_m = 450;
            int height_m = 450;
            stroke(255,50);
            strokeWeight(3);
            for(int i=0;i<width_m;i++)
            {
                for(int j=0;j<height_m;j++)
                {
                float margin = 50;
                float x = map(i,0,width_m-1,margin,width-margin);
                float y = map(j,0,height_m-1,margin,height-margin);

                float dx = 20.0*periodicFunction(t-offset(x,y),0,x,y);
                float dy = 20.0*periodicFunction(t-offset(x,y),123,x,y);

                point(x+dx,y+dy);
                }
            }
            break;

        case(PAYMENT):
            ps.run();
            if (playlist!= null) {
                // playlist[currentMovieIndex].stop();
                currentMovieIndex = 0;
                currentGridIndex = getGridIndex(ps_origin);
                ps_origin = getGridPosition(currentGridIndex).copy();
                playlist[currentMovieIndex].loop();
                image(playlist[currentMovieIndex], ps_origin.x - movieWidth / 2, ps_origin.y - movieHeight / 2, movieWidth, movieHeight);
            }
            break;
        case(INFOLINE):
            ps.run();
            if (playlist!= null) {
                // playlist[currentMovieIndex].stop();
                currentMovieIndex = 1;
                currentGridIndex = getGridIndex(ps_origin);
                movie_origin = getGridPosition(currentGridIndex).copy();
                playlist[currentMovieIndex].loop();
                image(playlist[currentMovieIndex], ps_origin.x - movieWidth / 2, ps_origin.y - movieHeight / 2, movieWidth, movieHeight);
            }
            break;
        case(INFOLINEDELAY):
            ps.run();
            if (playlist!= null) {
                // playlist[currentMovieIndex].stop();
                currentMovieIndex = 2;
                currentGridIndex = getGridIndex(ps_origin);
                movie_origin = getGridPosition(currentGridIndex).copy();
                playlist[currentMovieIndex].loop();
                image(playlist[currentMovieIndex], ps_origin.x - movieWidth / 2, ps_origin.y - movieHeight / 2, movieWidth, movieHeight);
            }
            break;
    }
}

void movieEvent(Movie m) {
    m.read();
}

void keyPressed() {
    switch(key) {
        case('e') : drawMode = RIPPLE; break;
        case('o') : drawMode = ONBOARDING; break;
        case('s') : drawMode = DRIVESTART; break;
        case('p') : drawMode = DRIVESTOP; break;
        case('r') : drawMode = RAIN; break;
        case('h') : drawMode = HEATWAVE; break;
        // movies
        case('0') : drawMode = PAYMENT; break;
        case('1') : drawMode = INFOLINE; break;
        case('2') : drawMode = INFOLINEDELAY; break;
    }
}

void addParticles(ParticleSystem ps) {
    stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
    fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB();    
    ps.addParticle(control_points, max_radius, min_radius, growth, 
        life_span, fade_speed, ripple_width, shape_fill, 
        shape_strtoke, stroke_color, fill_color);
}

void addShakes(ShakeSystem ss, int min_radius, int max_radius) {
    stroke_color = cp5.get(ColorWheel.class,"strokeCol").getRGB();
    fill_color = cp5.get(ColorWheel.class,"fillCol").getRGB(); 
    ss.addShake(control_points, max_radius, min_radius, growth, 
        life_span, fade_speed, ripple_width, shape_fill, 
        shape_strtoke, stroke_color, fill_color, radiusRate, circle_size);
}

void drawRain(int startFreq, PVector ps_origin, ParticleSystem ps, float[][] ps_origin_list, int[] radius_list, int rain_num) {
        ps.run();
        currentGridIndex = getGridIndex(ps_origin);
        freq = 60;
        growth = 6;
        life_span = 300;
        if (frameCount % freq == startFreq) {
            for(int i=0; i<rain_num; i++){
                int x = (int)random(width);
                ps.origin.x = x;
                switch (currentGridIndex) {
                    case 0:
                        if (x > width*2/3) {
                            int y = (int)random(height/2, height);
                            ps.origin.y = y;
                        } else {
                            int y = (int)random(height);
                            ps.origin.y = y;
                        }
                        break;
                    case 1:
                        if (x < width*2/3 && x > width/3) {
                            int y = (int)random(height/2, height);
                            ps.origin.y = y;
                        } else {
                            int y = (int)random(height);
                            ps.origin.y = y;
                        }
                        break;
                    case 2:
                        if (x < width/3) {
                            int y = (int)random(height/2, height);
                            ps.origin.y = y;
                        } else {
                            int y = (int)random(height);
                            ps.origin.y = y;
                        }
                        break;
                    case 3:
                        if (x > width*2/3) {
                            int y = (int)random(0, height/2);
                            ps.origin.y = y;
                        } else {
                            int y = (int)random(height);
                            ps.origin.y = y;
                        }
                        break;
                    case 4:
                        if (x < width*2/3 && x > width/3) {
                            int y = (int)random(0, height/2);
                            ps.origin.y = y;
                        } else {
                            int y = (int)random(height);
                            ps.origin.y = y;
                        }
                        break;
                    case 5:
                        if (x < width/3) {
                            int y = (int)random(0, height/2);
                            ps.origin.y = y;
                        } else {
                            int y = (int)random(height);
                            ps.origin.y = y;
                        }
                        break;
                }
                max_radius = (int)random(100);
                min_radius = max_radius;
                ps_origin_list[i][0] = ps.origin.x;
                ps_origin_list[i][1] = ps.origin.y;
                radius_list[i] = max_radius;
                addParticles(ps);
            }
        }
        if (frameCount % freq == startFreq + 15) {
            for(int i=0; i<rain_num; i++){ 
                ps.origin.x = ps_origin_list[i][0];
                ps.origin.y = ps_origin_list[i][1];
                max_radius = radius_list[i];
                min_radius = max_radius;
                addParticles(ps);
            }
        }
        if (frameCount % freq == startFreq + 20) {
            for(int i=0; i<rain_num; i++){
                ps.origin.x = ps_origin_list[i][0];
                ps.origin.y = ps_origin_list[i][1];
                max_radius = radius_list[i];
                min_radius = max_radius;
                addParticles(ps);
            }
        }

}

// logic for determining the grid position from the depth sensor input
int getGridIndex(PVector vector_origin) {
    max_grid_list.clear();
    
    int zone_0_count = 0;
    int zone_1_count = 0;
    int zone_2_count = 0;
    int zone_3_count = 0;
    int zone_4_count = 0;
    int zone_5_count = 0;
    
    // Step has direct impact to performance. Change according to canvas size.
    int step = 60;
    for (int x = 0; x < width; x +=step) {
        for (int y = 0; y < height; y +=step) {
            //  TODO: change accroding to canvas size
            float d = camera.getDistance(x / 5, y / 5);
            // float d = camera.getDistance(x / 3, y / 3);
            if (d > 0.5 && d <= 0.8) {
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
    int num_of_pixel_threshold = 80;
    if (Collections.max(max_grid_list) < num_of_pixel_threshold) {
        max_index = 99;
    } else {
        max_index = max_grid_list.indexOf(Collections.max(max_grid_list));
    }
    // println(max_grid_list);
    return max_index;
}

PVector getGridPosition(int max_index) {
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

float periodicFunction(float p,float seed,float x,float y)
{
  float radius = 1.3;
  float scl = 0.018;
//   float scl = 1;
  return 1.0*(float)noise.eval(seed+radius*cos(TWO_PI*p),radius*sin(TWO_PI*p),scl*x,scl*y);
}


float offset(float x,float y)
{
  return 0.015*dist(x,y,width/2,height/2);
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
