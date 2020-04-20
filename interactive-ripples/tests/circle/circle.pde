PVector center;
int numPoints=20;
int minRad = 100;
int maxRad = 200;
float [] pointsRadius = new float[numPoints];
float angle=TWO_PI/(float)numPoints;
int life = 100;
int growthSpeed = 2;
int rippleWidth = 5;


void setup() {
  size(700, 700);
  background(255);
  noFill();
  
  center  = new PVector(width/2, height/2);
  
  makeCircle();
  
}

void draw(){
  
  background(255);
  noFill();
  stroke(0, 0, 0, life);  
  strokeWeight(rippleWidth);     
  
  beginShape();
  curveVertex(center.x + pointsRadius[numPoints-1]*sin(angle*(numPoints-1)), center.y + pointsRadius[numPoints-1]*cos(angle*(numPoints-1)));
  for(int i=0;i<numPoints;i++)
  {
    pointsRadius[i] += growthSpeed;
    curveVertex(center.x + pointsRadius[i]*sin(angle*i), center.y + pointsRadius[i]*cos(angle*i));
  }
  curveVertex(center.x + pointsRadius[0]*sin(0), center.y + pointsRadius[0]*cos(0)); 
  curveVertex(center.x + pointsRadius[1]*sin(angle), center.y + pointsRadius[1]*cos(angle)); 
  endShape();

  life--;
  
  //reset and generate new circle
  if(life <= 1)
  {
    life = 100;
    makeCircle();
  }
  
}

//Generate an array of random radiuses which will be used to draw the circle
void makeCircle()
{
  for(int i=0;i<numPoints;i++){
    pointsRadius[i] = random(minRad, maxRad);
  }
}
