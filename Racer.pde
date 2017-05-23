class Racer {
  String racer_name;
  float[] laps;
  int time;
  int pause;
  int pausestart;
  int pauseend;
  int total_pause;
  boolean stop;
  int place;
  int row = 135;
  boolean highlight = false;
  int trike;

  Racer (String name, int lap_num, int place){
    racer_name = name;
    laps = new float[lap_num];
    stop = true;
    time=0;
    pause = 0;
    pausestart = 0;
    pauseend = 0;
    total_pause = 0;
    this.place = place;
    trike = place;
  }

  Racer (int place){
    racer_name = "";
    laps = new float[2];
    stop = true;
    time=0;
    pause = 0;
    pausestart = 0;
    pauseend = 0;
    total_pause = 0;
    this.place = place;
    trike = place;
  }

  String get_name(){
    return racer_name;
  }

  int get_time(){
    if ( stop ) {
      total_pause = (millis() - pausestart); //<>//
    }
    time = millis() - total_pause - pause;
    return time;
  }

  void start(){
    stop = false;
    pause = pause + total_pause;
    total_pause = 0;
  }

  void pause(){
    stop = true;
    pausestart = millis();
  }

  void reset_current(){
    pause = millis();
    pausestart=millis();
  }

  void toggle(){
    if ( stop ) {
      start();
    }
    else{
      pause();
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

  boolean hover(int mouse_y){
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

  void racerDisplay()
  {
    int time = get_time();
    String seconds;
    String minutes;
    String format_time;
    int row_position;
    int timer_col = 1105;

    row_position = row + ( 50 * place );

    seconds = String.format("%05.2f",time/1000.0 % 60.0,2);
    minutes = nf(time/60000,2);
    format_time = String.format("%s:%s", minutes, seconds);

    if (highlight){
      fill(255,255,255, 50);
      rect(165,row_position-30,700,38);
    }

    textAlign(LEFT);
    textSize(35);
    fill(255, 255, 255);

    //trike number
    text(trike, 45, row_position);

    //Racer
    text(racer_name, 165, row_position);

    //LAP1
    textAlign(RIGHT);
    text(format_time, timer_col, row_position);

    //LAP2
    timer_col = 1270;
    minutes = "00";
    seconds = "00.00";
    format_time = String.format("%s:%s", minutes, seconds);
    text(format_time, timer_col, row_position);

    //place
    textAlign(RIGHT);
    text( place +1 , 917, row_position);

     if( hover(mouseY)) {
       fill(220, 243, 14, 50);
       rect(0,row_position-30,1280,38);
     }

    //divider
    fill(220, 243, 14);
    rect(0,row_position + 12,1280,5);
  }

}
