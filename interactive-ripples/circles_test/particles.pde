// THE PARTICLE SYSYEM CALSS
class ParticleSystem {
  ArrayList particles;
  PVector origin;

  // Constructor
  ParticleSystem(PVector location) {
    origin = location.copy();
    particles = new ArrayList();
  }
 
  void addParticle() {
    particles.add(new Particle(origin));
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
  float[] pointsRadius;
  float angle;
  int numOfPoints;
  int minRad;
  int maxRad;
  boolean shapeFill;
  boolean shapeStrtoke;
  color fillCol;
  color strokeCol;
 
  // Coinstructor
  Particle(PVector l) {
    
    // How many points define the ripple shape
    numOfPoints = 20;    
    
    // How wiggly the shape will be
    minRad = 10;
    maxRad = 20;
    
    //how fast will the ripple grow/expand 
    growth = 3.0;
    
    // Lifespan Max value is 255
    // If the particle to be fully opaque when it first appears
    lifespan = 255.0; 
    
    // how fast the particles fade
    fadeSpeed = 5.0;
    
    // The width of the ripple shape stroke (if used)
    rippleWidth = 5;    
    
    // The color of the fill / stroke (feel free to add more colors)
    strokeCol = color(0, 255, 255);
    fillCol = color(255, 0, 255);

    //  Fill and stroke visibility
    shapeFill = true;
    shapeStrtoke = true;

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

  void run() {
    update();
    display();
  }

  // Update Particle shape / position / size
  void update() {
    // velocity.add(acceleration);
    // location.add(velocity);
    for(int i=0;i<numOfPoints;i++)
    {
      pointsRadius[i] += growth;
    }
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
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
