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
 
  // Coinstructor
  Particle(PVector l) {
    numOfPoints = 20;    
    minRad = 5;
    maxRad = 20;
    growth = 3;
    location = l.copy();
    angle = TWO_PI/(float)numOfPoints;
    lifespan = 100.0;
    fadeSpeed = 1;
    rippleWidth = 5;    
    
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
    noFill();
    fill(255, 255, 255, lifespan);
    noStroke();
    // stroke(255, 255, 255, lifespan);  
    // strokeWeight(rippleWidth); 
      
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
