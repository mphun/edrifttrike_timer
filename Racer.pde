/**
* The Racer Class store racers times
* it also store logical to draw the racers time
*/
class Racer {
  String racer_name;
  int[] laps;
  int[] pause;
  int[] pause_start;
  int[] pause_current;
  boolean stop;
  //int place;
  int row = 135;
  boolean highlight = false;
  int trike;
  int text_alpha = 255;
  String ir_code;
  int ir_delay = millis();

  Racer (int trike, int lap_num, String ir_code){
    racer_name = ir_code;
    laps = new int[lap_num];
    pause = new int[lap_num];
    pause_current = new int[lap_num];
    pause_start = new int[lap_num];
    stop = true;
    this.trike = trike;
    this.ir_code = ir_code;
  }

  /**
  * this function will save a screenshot of current time plus save //<>//
  * the data in json format
  * @param args Unused.
  * @return String This return the name of the racer.
  */
  String get_name(){
    return racer_name;
  }

  /**
  * sets the current tracked time to get ready to be displayed
  * @param lap_num the current lap
  * @return Nothing.
  */
  void get_time(int lap_num){
    if ( stop ) {
      pause_current[lap_num] = (millis() - pause_start[lap_num]);
    }
    laps[lap_num] = millis() - pause_current[lap_num] - pause[lap_num];
  }

  /**
  * start the timer for the racer
  * @param lap_num the current lap
  * @return Nothing.
  */
  void start(int lap_num){
    if ( stop ){
      stop = false;
      pause[lap_num] = pause[lap_num] + pause_current[lap_num];
      pause_current[lap_num] = 0;
    }
  }

  /**
  * pause the timer for the given lap
  * @param lap_num the current lap
  * @return Nothing.
  */
  void pause(int lap_num){
    if ( !stop ){
      stop = true;
      pause_start[lap_num] = millis();
    }
  }

  /**
  * reset the timer for the racer
  * @param lap_num the current lap
  * @return Nothing.
  */
  void reset_current(int lap_num){
    pause[lap_num] = millis();
    pause_start[lap_num] = millis();
  }

  /**
  * toggle the start and top for the timer of the racer
  * @param lap_num the current lap
  * @return Nothing.
  */
  void time_toggle(int lap_num){
    if ( stop ) {
      start(lap_num);
    }
    else{
      pause(lap_num);
    }
  }

  /**
  * append a character to the name of the racer
  * @param letter the char to be used to spell the racers name
  * @return Nothing.
  */
  void add_char(char letter){
    racer_name +=  letter;
  }

  /**
  * pop the last chacter of the racer's name
  * @param args Unused
  * @return Nothing.
  */
  void delete_char(){
   racer_name = racer_name.replaceFirst(".$", "");
  }

  /**
  * toggle the highlight variable which it used to animate the blinking highlight on racers name
  * @param args Unused
  * @return Nothing.
  */
  void highlight_toggle(){
      highlight = !highlight;
  }

  /**
  * turn off highlight
  * @param args Unused
  * @return Nothing.
  */
  void highlight_off(){
      highlight = false;
  }

  /**
  * dim the text at a certain rate
  * @param args Unused
  * @return Nothing.
  */
  void dim_text(){
    text_alpha -= 3;
  }

  /**
  * brighten text at a certain rate
  * @param args Unused
  * @return Nothing.
  */
  void light_text(){
    text_alpha += 3;
  }

  /**
  * get the transparent rate for the text
  * @param args Unused
  * @return int the transparent number for the racer's text
  */
  int get_text_alpha(){
    return text_alpha;
  }

  /**
  * return the best lap for the racer
  * @param args Unused
  * @return int the best time
  */
  int get_best_time(){
    int best = laps[0];
    for (int i = 1; i < laps.length; i++){
      if ( laps[i] < best && laps[i] > 0){
        best = laps[i];
      }
    }
    return best;
  }

  /**
  * determines whether the mouse is hovering over the racers name
  * @param mouse_y the y position of the mouse
  * @param place the column position of the racer in the display
  * @return boolean return whether mouse is over the name.
  */
  boolean hover(int mouse_y, int place){
    int row_position;

    row_position = row + ( 50 * place );
    int lower_bound = row_position - 15;
    int upper_bound = row_position + 15;
    if ( mouse_y > lower_bound && mouse_y < upper_bound ){
      return true;
    }
    else{
      return false;
    }
  }

  /**
  * format the racers time into a jsonobject
  * @param args Unused
  * @return JSONOBJECT racers time in a json format
  */
  JSONObject get_racer_json(){
    JSONObject racer = new JSONObject();

    racer.setString("name", racer_name);
    racer.setInt("time", get_best_time());

    return racer;
  }

  /**
  * animate the racers time on the screen
  * @param lap_num the time of a particular lap
  * @param place the column position of the racer
  * @return Nothing.
  */
  void racerDisplay(int lap_num, int place)
  {
    String seconds;
    String minutes;
    String format_time;
    int row_position;
    int timer_col = 1105;

    get_time(lap_num);
    row_position = row + ( 50 * place );

    if (highlight){
      fill(255,255,255, 50);
      rect(165,row_position-30,700,38);
    }

    textAlign(LEFT);
    textSize(35);
    fill(255, 255, 255, text_alpha);

    //trike number
    text(trike, 45, row_position);

    //Racer
    text(racer_name, 165, row_position);

    //place
    textAlign(RIGHT);
    text( place +1 , 917, row_position);

    //divider
    fill(220, 243, 14);
    rect(0,row_position + 12,1280,5);

    //Racers time
    textAlign(RIGHT);
    for ( int i = 0; i < laps.length; i ++ ){
      if ( lap_num == i ){
        fill(255, 255, 255, text_alpha);
      }
      else{
        fill(255, 255, 255, text_alpha/2);
      }
      seconds = String.format("%05.2f",laps[i]/1000.0 % 60.0,2);
      minutes = nf(laps[i]/60000,2);
      format_time = String.format("%s:%s", minutes, seconds);
      text(format_time, timer_col + (165 * i), row_position);
    }

    if( hover(mouseY, place)) {
      fill(220, 243, 14, 50);
      rect(0,row_position-30,1280,38);
    }
  }
  void is_ir_match(String hex_code, int current_lap){
    if ( hex_code != null && hex_code.equals(ir_code) && ir_delay + 1000 < millis()) {
      this.time_toggle(current_lap);
      ir_delay = millis();
    }
  }

}

/**
* provides the ability to sort class objects by chosen object attribues
*/
class CompareRacers implements Comparator {
  int compare(Object o1, Object o2) {
      int racer1 = ((Racer) o1).get_best_time();
      int racer2 = ((Racer) o2).get_best_time();
      if (racer1 < racer2 && racer1 > 0){
        return -1;
      }
      if ( racer1 == racer2 ){
         return 0;
      }
      if (racer2 > racer1 || racer2 == 0){
         return 1;
      }
      return 500;
  }
}