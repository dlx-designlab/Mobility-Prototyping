import java.util.Iterator;
ParticleSystem ps;

PVector ps_origin = new PVector(width/2, height/2); 

void setup() {
  size(1280, 720);
  
  ps = new ParticleSystem(ps_origin);
}
 
void draw() {
  background(255);
  ps.run();
  ps.addParticle();
  
  ps_origin.x = mouseX;
  ps_origin.y = mouseY;
  
  ps.origin = ps_origin.copy();
  
}
