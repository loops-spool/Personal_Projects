public class daily_box_class
{
  float stroke_weight = GRID_STROKE_WEIGHT;
  // Stroke weights gonna be tricky to increase if you ever want to
    // May need to increase the width and the column size (keep it to ints!)
      // But idk, it works for 1 and its close for anything else
  float box_width = COL_SIZE;
  float box_height = ROW_SIZE;
  int day_number = 0;
  String[] check_off_items = {"Do morning routine", 
                              "Be present", 
                              "Do thing you love", 
                              "Spend time w/ self", 
                              "Do list"};

  void display(int day_num)
  {
    push();
      fill(360);
      noFill();
      stroke(0);
      strokeWeight(stroke_weight);
      
      rect(0, 0, box_width, box_height);
      stroke(180);
      line(0, 1, box_width, 1);
      line(0, box_height - 1, box_width, box_height - 1);
      
    
    pop();
  }
}
