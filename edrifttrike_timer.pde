PImage bg;
Racer[] racers = new Racer[4];
void setup()
{
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
      for (int i = 0; i < racers.length -1; i++){
        racers[i].reset_current();
      }
      break;
  }
}