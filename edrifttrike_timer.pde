/**
* This is a timer program that keeps track of individual racer's time in a non
* serial manner. it is meant to work with a infrared tracking system or keyboard actions
*
* @author Michael Phun
* @version 0.1
* @since 2017-06-08
*/


import java.util.Arrays;
import java.util.Comparator;
import static javax.swing.JOptionPane.*;
import java.util.*;
import java.text.SimpleDateFormat;
import processing.serial.*;

PImage bg;
int number_of_racers;   // the number of racers that is particpating
int current_edit = -1;  // use to determine which racer to edit the racer's name or reset their time
int LAPS = 2;           // number of laps each racers gets
int current_lap = 0;    // keep track of the current lap racers are on
JSONObject config;       // configuration data from the conf data
JSONArray ir_codes;       // stores ircodes
int serial_num;
boolean dim = false;    // when to dim racers times to sort
boolean light = false;  // when to show racers time after sort
boolean serial_connection = false; //indicate whether serial connection has been establish
Serial myPort;
String serial_val;      // stor serial data in a string format
Racer[] racers;

//next button positions
int next_x = 950;
int next_y = 650;

//reset button positions
int reset_x = 1060;
int reset_y = 650;

//save button postions
int save_x = 1170;
int save_y = 650;

//general button size
int button_width = 100;
int button_height = 50;
void setup()
{
  config = loadJSONObject("config.json");
  ir_codes = config.getJSONArray("ir_code");
  serial_num = config.getInt("serial_ports");
  println(serial_num);
  println("list of serials:");
  String portName = Serial.list()[serial_num];
  printArray(Serial.list());
  try{
    myPort = new Serial(this, portName, 9600);
    println("serial port " + portName + " Connected!!");
    serial_connection = true;
  }catch(Exception e){
    println("serial port " + portName + " is not connected, skipping now");
  }
  number_of_racers = ir_codes.size();
  racers = new Racer[number_of_racers];
  for (int i = 0; i < racers.length; i++){
     racers[i] = new Racer(i, LAPS, ir_codes.getJSONObject(i).getString("ir_code"));
  }
  size (1280, 720);
  bg = loadImage("trike_timer_3.png");
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
  if ( serial_connection ){
    serialport_actions();
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

/**
* this function will activate the next lap for timing
* @param args Unused.
* @return Nothing.
*/
void next_lap () {
  for (int i = 0; i < racers.length; i++){
    racers[i].pause(current_lap);
  }


  current_lap = (current_lap +1) % LAPS;
}

/**
* this function will reset all Racers or an individual Racer
* @param args Unused.
* @return Nothing.
*/
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

/**
* This function stop the highlight animation when editing a racer's name
* @param args Unused.
* @return Nothing.
*/
void returnFromEdit(){
  for (int i = 0; i < racers.length; i++){
    racers[i].highlight_off();
    current_edit=-1;
  }
}

/**
* this function will save a screenshot of current time plus save
* the data in json format
* @param args Unused.
* @return Nothing.
*/
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

/**
* This function will read the data from the serial port and check if the string matches the racers.
* if it does it will toggle the time.
* @param args Unused.
* @return Nothing.
*/
void serialport_actions(){
  char newline = 10;
  if ( myPort.available() > 0) {
    serial_val = myPort.readStringUntil(newline);
    if ( serial_val != null ){
      println(trim(serial_val));
      for (int i = 0; i < racers.length; i++){
        racers[i].is_ir_match(trim(serial_val), current_lap);
      }
    }
  }
}