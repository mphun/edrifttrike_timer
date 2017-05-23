import processing.serial.*;
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

PImage bg;
//Racer racer1 = new Racer("mikey",2,0);
Racer racer2 = new Racer("joe",2,1);
Racer[] racers = new Racer[4];
void setup()
{
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');

  size (1280, 720);
  bg = loadImage("trike_timer_3.png");
  for (int i = 0; i < racers.length; i++){
    println(i);
     racers[i] = new Racer(i);
  }
  racers[0] = new Racer("mikey",2,0); //<>//
}

void draw()
{
  String signal="";
  if ( myPort.available() > 0) {  // If data is available,
    for ( int i=0; i < 8; i++){
       val = myPort.read();
       signal += char(val);
    }
    println(mouseY);
    println(signal);
    if ( match(signal, ".*FE808A75.*" ) != null){
     racers[0].toggle();
    }
    if ( match(signal, ".*804AB5.*" ) != null){
     racers[1].toggle();
    }
    if ( signal == "706956485665555313FE808A75" ){
     racers[1].toggle();
    }
  }
  background(bg);
  for (int i = 0; i < racers.length -1; i++){
    racers[i].racerDisplay();
  } //<>//
}

void keyPressed() {
  int key_int;
  if( match(str(key),"[0-9]") != null){
   key_int = int(key) - '0' - 1;
   racers[key_int].toggle();
  }

  switch(key){
    case 'r':
     racers[0].reset_current();
     racers[1].reset_current();
     racers[2].reset_current();
     break;
  }
}
