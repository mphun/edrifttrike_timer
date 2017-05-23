PImage bg;
int RACER_NUM = 4;
int current_edit= -1;
Racer[] racers = new Racer[RACER_NUM];
void setup()
{
  size (1280, 720);
  bg = loadImage("trike_timer_3.png");
  for (int i = 0; i < racers.length; i++){
     racers[i] = new Racer(i);
  } //<>//
}

void draw()
{
  background(bg);
  for (int i = 0; i < racers.length -1; i++){
    racers[i].racerDisplay();
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
        current_edit = (next_edit +1) % (RACER_NUM -1);
        println(current_edit);
        break;
      default:
        racers[current_edit].add_char(key);
    }
  }
  else {
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
}

void mousePressed() {
  returnFromEdit();
  for (int i = 0; i < racers.length -1; i++){
    if ( racers[i].hover(mouseY)) {
       println(i);
       current_edit = i;
    }
  }
}

void returnFromEdit(){
  for (int i = 0; i < racers.length -1; i++){
    racers[i].highlight_off();
    current_edit=-1;
  }
}
