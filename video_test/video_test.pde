import processing.video.*;
Movie myMovie;

void setup() {
  size(1000, 1000);
  myMovie = new Movie(this, "fire.mp4");
  myMovie.loop();
}

void draw() {
  tint(255, 20);
  image(myMovie, 0, 0);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
