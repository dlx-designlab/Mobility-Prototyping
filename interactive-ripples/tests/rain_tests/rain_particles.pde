// THE PARTICLE SYSYEM CALSS
class RainParticleSystem {
  ArrayList particles;
  PVector origin;

  // Constructor
  RainParticleSystem(PVector location) {
    origin = location.copy();
    particles = new ArrayList();
  }
 
  void addParticle(int maxRad, int minRad, float growRate, 
                    int lifeSpan, float fadeSpeed, int rippleWidth, 
                    boolean shapeFill, boolean shapeStrtoke, color strokeColor, color fillColor) {
    particles.add(new Particle(origin, maxRad, minRad, growRate, lifeSpan, fadeSpeed, 
                                rippleWidth, shapeFill, shapeStrtoke, strokeColor, fillColor));
  }

  // Update all the particles in the system
  void run() {
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
  float rippleRadius;
  float angle;
  int minRad;
  int maxRad;
  float rippleRings[];
  boolean shapeFill;
  boolean shapeStrtoke;
  color fillCol;
  color strokeCol;
 
  // Coinstructor
  Particle(PVector l, int maxR, int minR, float growRate, 
                    int lifeSpan, float fadeSpd, int rippleW, 
                    boolean shpFill, boolean shpStrtoke, color strkColor, color fillColor) {
        
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

  void run() {
    update();
    display();
  }

  // Update Particle shape / position / size
  void update() {
    // velocity.add(acceleration);
    // location.add(velocity);
    rippleRadius += growth;
    lifespan -= fadeSpeed;
  }
 
  // Draw the particle
  void display() {

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

      ellipse(location.x, location.y, rippleRadius, rippleRadius);
  
  }

  // Check if particle reached end of life
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
