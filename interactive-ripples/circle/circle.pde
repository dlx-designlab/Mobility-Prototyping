PVector center;
int numPoints=15;
float [] pointsRadius = new float[numPoints];
float angle=TWO_PI/(float)numPoints;
int life = 100;
int growth = 2;

void setup() {
  size(700, 700);
  background(255);
  noFill();
  stroke(40, 40, 0);
  strokeWeight(6);
  
  center  = new PVector(width/2, height/2);
  

  makeCircle();
  
}

void draw(){
  
  background(255);
  noFill();
  strokeWeight(6);
     
  beginShape();
  for(int i=0;i<numPoints;i++)
  {
    
    pointsRadius[i] += growth;
    stroke(0, 0, 0, life);
    curveVertex(center.x + pointsRadius[i]*sin(angle*i), center.y + pointsRadius[i]*cos(angle*i));
  
  }
  endShape();
  
  life--;
  
  if(life <= 1)
  {
    life = 100;
    makeCircle();
  }
  
}


void makeCircle()
{
  for(int i=0;i<numPoints;i++){
    pointsRadius[i] = random(100, 200);
  }
}
