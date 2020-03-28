import java.util.Iterator;
ParticleSystem ps;
PVector ps_origin;

void setup() {
  // Set Canvas Size
  size(800, 800);
  frameRate(30);

  // Add new particle system
  ps_origin = new PVector(width/2, height/2); 
  ps = new ParticleSystem(ps_origin);
}
 
void draw() {
  background(0);  
  
  // update particle system position
  ps_origin.x = mouseX;
  ps_origin.y = mouseY;
  ps.origin = ps_origin.copy();

  // calculate and update all particle system elemets
  ps.run();
  
  // add new particle to the system every x frames 
  if (frameCount % 10 == 0){
    ps.addParticle();
  }
  
  // Add a blur effect (might be slow on hight resolution canvas)
  //filter(BLUR, 2);
  
}
