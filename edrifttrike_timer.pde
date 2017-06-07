import java.util.Arrays;
import java.util.Comparator;
import static javax.swing.JOptionPane.*;
import java.util.*;
import java.text.SimpleDateFormat;
import processing.serial.*;

PImage bg;
int number_of_racers;
int current_edit = -1;
int LAPS = 2;
int current_lap = 0;
JSONArray config;

//next button
int next_x = 950;
int next_y = 650;
int reset_x = 1060;
int reset_y = 650;
int save_x = 1170;
int save_y = 650;
int button_width = 100;
int button_height = 50;
boolean dim = false;
boolean light = false;
boolean save_sign = false;
int time_delay = 0;

Serial myPort;

String serial_val;

Racer[] racers;
void setup()
{
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);

  config = loadJSONArray("config2.json");
  number_of_racers = config.size();
  racers = new Racer[number_of_racers];

  size (1280, 720);
  bg = loadImage("trike_timer_3.png");
  for (int i = 0; i < racers.length; i++){
     racers[i] = new Racer(i, LAPS, config.getJSONObject(i).getString("ir_code"));
  }
}

void draw()
{
  background(bg);
  for (int i = 0; i < racers.length; i++){
    racers[i].racerDisplay(current_lap, i);
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
  textAlign(CENTER, TOP);
  textSize(35);
  text("Next", next_x, next_y, button_width, button_height);

  //Reset button
  fill(220, 243, 14);
  rect(reset_x, reset_y, button_width, button_height, 10);
  fill(0, 0, 0);
  textAlign(CENTER, TOP);
  textSize(35);
  text("Reset", reset_x, reset_y, button_width, button_height);

  //save button
  fill(220, 243, 14);
  rect(save_x, save_y, button_width, button_height, 10);
  fill(0, 0, 0);
  textAlign(CENTER, TOP);
  textSize(35);
  text("Save", save_x, save_y, button_width, button_height);

  //animate sorting racers
  if ( dim ){
    if ( racers[0].get_text_alpha() > 0 ){
      for (int i = 0; i < racers.length; i++){
        racers[i].dim_text();
      }
    }
    else{
      dim = false;
      Arrays.sort(racers, new CompareRacers());
      delay(3);
      next_lap();
      light = true;
    }
  }

  if ( light ){
    if ( racers[0].get_text_alpha() < 255 ){
      for (int i = 0; i < racers.length; i++){
        racers[i].light_text();
      }
    }
    else{
      light = false;
    }
  }

  serialport_actions();

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
        dim = true;
        break;
      case 's':
        save();
        break;
    }
  }
}

void mousePressed() {
  if ( mouseX > next_x && mouseX < (next_x + button_width) && mouseY > next_y && mouseY < (next_y + button_height) ){
    dim = true;
  }
  if ( mouseX > save_x && mouseX < (save_x + button_width) && mouseY > save_y && mouseY < (save_y + button_height) ){
    save();
  }
  if ( mouseX > reset_x && mouseX < (reset_x + button_width) && mouseY > reset_y && mouseY < (reset_y + button_height) ){
    reset_lap();
  }
  else{
    returnFromEdit();
  }
  for (int i = 0; i < racers.length; i++){
    if ( racers[i].hover(mouseY, i)) {
       current_edit = i;
    }
  }
}

void next_lap () {
  for (int i = 0; i < racers.length; i++){
    racers[i].pause(current_lap);
  }


  current_lap = (current_lap +1) % LAPS;
}

void reset_lap () {
  println(current_edit);
  if ( current_edit >= 0 ) {
    racers[current_edit].reset_current(current_lap);
  }
  else {
    for (int i = 0; i < racers.length; i++){
      racers[i].reset_current(current_lap);
    }
  }
}

void returnFromEdit(){
  for (int i = 0; i < racers.length; i++){
    racers[i].highlight_off();
    current_edit=-1;
  }
}

void save(){

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH-mm");
  Date date = new Date();

  saveFrame("screenshot/screenshot-#####.png");
  showMessageDialog(null, "Screenshot Saved", "SAVED", INFORMATION_MESSAGE);
  JSONArray racers_data = new JSONArray();
  for (int i = 0; i < racers.length; i++){
    racers_data.setJSONObject(i,racers[i].get_racer_json());
  }

  saveJSONArray(racers_data, "data/race_time" + sdf.format(date.getTime()) + ".json");
}

void serialport_actions(){
  if ( myPort.available() > 0) {
    serial_val = myPort.readStringUntil(10);
    if ( serial_val != null ){
      println(trim(serial_val));
      for (int i = 0; i < racers.length; i++){
        racers[i].is_ir_match(trim(serial_val), current_lap);
      }
    }
  }
}
