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
    racer_name = "";
    laps = new int[lap_num];
    pause = new int[lap_num];
    pause_current = new int[lap_num];
    pause_start = new int[lap_num];
    stop = true;
    this.trike = trike;
    this.ir_code = ir_code;
  }

  String get_name(){
    return racer_name;
  }

  void get_time(int lap_num){
    if ( stop ) { //<>// //<>//
      pause_current[lap_num] = (millis() - pause_start[lap_num]);
    }
    laps[lap_num] = millis() - pause_current[lap_num] - pause[lap_num];
  }

  void start(int lap_num){
    if ( stop ){
      stop = false;
      pause[lap_num] = pause[lap_num] + pause_current[lap_num];
      pause_current[lap_num] = 0;
    }
  }

  void pause(int lap_num){
    if ( !stop ){
      stop = true;
      pause_start[lap_num] = millis();
    }
  }

  void reset_current(int lap_num){
    pause[lap_num] = millis();
    pause_start[lap_num] = millis();
  }

  void time_toggle(int lap_num){
    if ( stop ) {
      start(lap_num);
    }
    else{
      pause(lap_num);
    }
  }

  void add_char(char letter){
    racer_name +=  letter;
  }

  void delete_char(){
   racer_name = racer_name.replaceFirst(".$", "");
  }

  void highlight_toggle(){
      highlight = !highlight;
  }

  void highlight_off(){
      highlight = false;
  }

  void dim_text(){
    text_alpha -= 3;
  }

  void light_text(){
    text_alpha += 3;
  }

  int get_text_alpha(){
    return text_alpha;
  }

  int get_best_time(){
    int best = laps[0];
    for (int i = 1; i < laps.length; i++){
      if ( laps[i] < best && laps[i] > 0){
        best = laps[i];
      }
    }
    return best;
  }

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

  JSONObject get_racer_json(){
    JSONObject racer = new JSONObject();

    racer.setString("name", racer_name);
    racer.setInt("time", get_best_time());

    return racer;
  }

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
