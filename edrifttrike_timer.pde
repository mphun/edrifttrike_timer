PImage bg;
int number_of_racers;
int current_edit = -1;
int LAPS = 2;
int current_lap = 0;
JSONObject config;

//next button
int next_x = 978;
int next_y = 650;
int button_width = 100;
int button_height = 50;
int reset_x = 1098;
int reset_y = 650;

Racer[] racers;
void setup()
{
  config = loadJSONObject("config.json");
  number_of_racers = config.getInt("number_of_racers");
  racers = new Racer[number_of_racers];

  size (1280, 720);
  bg = loadImage("trike_timer_3.png");
  for (int i = 0; i < racers.length; i++){
     racers[i] = new Racer(i, LAPS);
  }
}

void draw()
{
  background(bg);
  for (int i = 0; i < racers.length; i++){
    racers[i].racerDisplay(current_lap);
  }
  if ( current_edit >= 0 ) {
    if (frameCount% 20== 0) {
      racers[current_edit].highlight_toggle();
    }
  }

  //Next button
  fill(220, 243, 14);
  rect(next_x, next_y, button_width, button_height, 10);
  fill(0, 0, 0);
  textSize(35);
  text("Next", next_x + 90, next_y + 38);

  //Reset button
    fill(220, 243, 14);
  rect(reset_x, reset_y, button_width, button_height, 10);
  fill(0, 0, 0);
  textSize(35);
  text("Reset", reset_x + 95, reset_y + 38);

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
        current_edit = (next_edit +1) % number_of_racers;
        break;
      default:
        racers[current_edit].add_char(key);
    }
  }
  else {
    if( match(str(key),"[1-9]") != null){
      if ( (key - '0') <= number_of_racers ){
        key_int = int(key) - '0' - 1;
        racers[key_int].time_toggle(current_lap);
      }
    }
    switch(key){
      case 'r':
        reset_lap();
        break;
      case 'n':
        next_lap();
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
  if ( mouseX > next_x && mouseX < (next_x + button_width) && mouseY > next_y && mouseY < (next_y + button_height) ){
    next_lap();
  }
  if ( mouseX > reset_x && mouseX < (reset_x + button_width) && mouseY > reset_y && mouseY < (reset_y + button_height) ){
    reset_lap();
  }
}

void next_lap () {
  for (int i = 0; i < racers.length; i++){
    racers[i].pause(current_lap);
  }
  current_lap = (current_lap +1) % LAPS;
}

void reset_lap () {
  for (int i = 0; i < racers.length; i++){
    racers[i].reset_current(current_lap);
  }
}

void returnFromEdit(){
  for (int i = 0; i < racers.length; i++){
    racers[i].highlight_off();
    current_edit=-1;
  }
}
