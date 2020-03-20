class ParticleSystem {
  ArrayList particles;
  PVector origin;

  ParticleSystem(PVector location) {
    origin = location.copy();
    particles = new ArrayList();
  }
 
  void addParticle() {
    particles.add(new Particle(origin));
  }

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


class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float size;
  float growth;
  float lifespan;
 
  Particle(PVector l) {
    size = 0;
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-2,2),random(-2,2));
    growth = random(0,3);
    location = l.copy();
    lifespan = 1000.0;
  }

  void run() {
    update();
    display();
  }
 
  void update() {
    velocity.add(acceleration);
    // location.add(velocity);
    size += growth;
    lifespan -= 5.0;
  }
 
  void display() {
    strokeWeight(0);
    stroke(0,lifespan);
    fill(255,lifespan);
    ellipse(location.x, location.y, size, size);
  }

  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
