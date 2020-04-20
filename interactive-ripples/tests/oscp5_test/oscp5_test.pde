import oscP5.*;
import netP5.*;


OscP5 oscP5;
NetAddress myBroadcastLocation; 

PVector pos;

void setup() {
  size(1000,1000, P2D);
  frameRate(10);
  
  /* create a new instance of oscP5. 
   * 5005 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this,5005);
  
  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress("127.0.1.1",5006);
  
  pos = new PVector(0,0); 
}


void draw() {
  background(0);
  ellipse(pos.x*100, pos.y*100, 50.0, 50.0);
  
}


void keyPressed() {
  OscMessage m;
  switch(key) {
    case('c'):
      /* connect to the broadcaster */
      m = new OscMessage("/server/connect",new Object[0]);
      oscP5.flush(m,myBroadcastLocation);  
      break;
    case('d'):
      /* disconnect from the broadcaster */
      m = new OscMessage("/server/disconnect",new Object[0]);
      oscP5.flush(m,myBroadcastLocation);  
      break;

  }  
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  //println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  //theOscMessage.print();
  
  pos = new PVector(theOscMessage.get(1).intValue(), theOscMessage.get(0).intValue());
  println(pos);
  
  
  
}
