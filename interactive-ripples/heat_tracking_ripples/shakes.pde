// THE SHAKE SYSYEM CALSS
class ShakeSystem {
  ArrayList shakes;
  PVector origin;

  // Constructor
  ShakeSystem(PVector location) {
    origin = location.copy();
    shakes = new ArrayList();
  }
 
  void addShakes(int ctlPts, int maxRad, int minRad, float growRate, 
                    int lifeSpan, float fadeSpeed, int rippleWidth, 
                    boolean shapeFill, boolean shapeStrtoke, color strokeColor, color fillColor, int radiusRate) {
    shakes.add(new Shake(origin, ctlPts, maxRad, minRad, growRate, lifeSpan, fadeSpeed,
                                rippleWidth, shapeFill, shapeStrtoke, strokeColor, fillColor, radiusRate));
  }

  // Update all the arcs in the system
  void run() {
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
  color fillCol;
  color strokeCol;
  int radiusRate;
 
  // Coinstructor
  Shake(PVector l, int ctlPts, int maxR, int minR, float growRate, 
                    int lifeSpan, float fadeSpd, int rippleW, 
                    boolean shpFill, boolean shpStrtoke, color strkColor, color fillColor, int radiusR) {
    
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
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
