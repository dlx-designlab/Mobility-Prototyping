import java.util.Iterator;
ParticleSystem ps;

PVector ps_origin = new PVector(width/2, height/2); 

void setup() {
  size(1280, 720);
    frameRate(30);
  ps = new ParticleSystem(ps_origin);
}
 
void draw() {
  background(0);  
  ps_origin.x = mouseX;
  ps_origin.y = mouseY;
  ps.origin = ps_origin.copy();

  ps.run();
  
  if (frameCount % 3 == 0){
    ps.addParticle();
  }

  
  
}
