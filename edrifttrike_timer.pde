PImage bg;
int RACER_NUM = 5;
int current_edit = -1;
int LAPS = 2;
int current_lap = 0;
Racer[] racers = new Racer[RACER_NUM];
void setup()
{
  size (1280, 720);
  bg = loadImage("trike_timer_3.png");
  for (int i = 0; i < racers.length; i++){
     racers[i] = new Racer(i, LAPS);
  } //<>//
}

void draw()
{
  background(bg);
  for (int i = 0; i < racers.length; i++){
    racers[i].racerDisplay(current_lap);
  } //<>//
  if ( current_edit >= 0 ) {
    if (frameCount% 20== 0) {
      racers[current_edit].highlight_toggle();
    }
  }

}

void keyPressed() {
  int key_int;
  int next_edit;

  if ( current_edit >= 0 ) {
    switch(key){
      case '\b':
        racers[current_edit].delete_char();
        break;
      case ENTER:
        returnFromEdit();
        break;
      case TAB:
        next_edit = current_edit;
        returnFromEdit();
        current_edit = (next_edit +1) % RACER_NUM;
        break;
      default:
        racers[current_edit].add_char(key);
    }
  }
  else {
    if( match(str(key),"[1-9]") != null){
      if ( (key - '0') <= RACER_NUM ){
        key_int = int(key) - '0' - 1;
        racers[key_int].time_toggle(current_lap);
      }
    }
    switch(key){
      case 'r':
        for (int i = 0; i < racers.length; i++){
          racers[i].reset_current(current_lap);
        }
        break;
      case 'n':
        for (int i = 0; i < racers.length; i++){
          racers[i].pause(current_lap);
        }
        current_lap = (current_lap +1) % LAPS;
        break;

    }
  }
}

void mousePressed() {
  returnFromEdit();
  for (int i = 0; i < racers.length; i++){
    if ( racers[i].hover(mouseY)) {
       current_edit = i;
    }
  }
}

void returnFromEdit(){
  for (int i = 0; i < racers.length; i++){
    racers[i].highlight_off();
    current_edit=-1;
  }
}
