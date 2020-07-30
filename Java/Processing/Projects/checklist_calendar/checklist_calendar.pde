import java.util.*;  // For Date
import java.time.*;  // For LocalDate
import processing.pdf.*;  // To convert to PDF

// TODO: Fix lines bleeding into month header (line cap?)

// GENERAL DATE STUFF
String[] WEEKDAYS = {"MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"};

// CURENT DATE STUFF
Date CURRENT_DATE;
LocalDate LOCAL_DATE;
int YEAR, MONTH, DAY;
String DAY_NAME;
String MONTH_NAME;
String MONTH_AND_YEAR;
String FIRST_DAY_OF_MONTH_NAME;
int DAYS_IN_MONTH;

// CALENDAR ALIGNMENTS
float MONTH_BOX_HEIGHT;
float DAY_NAME_BOX_HEIGHT = 25;


void setup()
{
  //size(825, 638);
  size(825, 638, PDF, "calendar_test.pdf");
  surface.setLocation(50, 50);
  colorMode(HSB, 360, 100, 100, 100);
  textAlign(CENTER, CENTER);
  background(360);
  
  MONTH_BOX_HEIGHT = height/6;
  
  CURRENT_DATE = new Date();
  LOCAL_DATE = CURRENT_DATE.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
  LOCAL_DATE = LOCAL_DATE.minusMonths(5);
  YEAR = LOCAL_DATE.getYear();
  MONTH = LOCAL_DATE.getMonthValue();
  DAY = LOCAL_DATE.getDayOfMonth();
  DAY_NAME = LOCAL_DATE.getDayOfWeek().toString();
  MONTH_NAME = LOCAL_DATE.getMonth().toString();
  FIRST_DAY_OF_MONTH_NAME = LOCAL_DATE.minusDays(DAY-1).getDayOfWeek().toString();
  MONTH_AND_YEAR = MONTH_NAME + " " + YEAR;
  
  DAYS_IN_MONTH = LOCAL_DATE.lengthOfMonth();
}

void draw()
{
  // Month name "text box"
  noStroke();
  fill(22, 100, 100);
  rect(0, 0, width, MONTH_BOX_HEIGHT);
  fill(360);
  textSize(60);
  text(MONTH_AND_YEAR, width/2, MONTH_BOX_HEIGHT/2.3);
  
  // Calendar grid lines
  push();
    strokeWeight(1);
    stroke(0);
    translate(0, MONTH_BOX_HEIGHT);
    // VERTICAL LINES
    float x;
    for (int i = 0; i < 7; i++)
    {
      x = i * (width/7);
      line(x, 0, x, height);
    }
    
    // HORIZONTAL LINES
    // DAY NAME LINE  
    //strokeWeight(2);
    //line(0, 0, width, 0);
    translate(0, DAY_NAME_BOX_HEIGHT);
    push();
      strokeWeight(2);
      line(0, 0, width, 0);
      noStroke();
      fill(0);
      textSize(15);
      for (int i = 0; i < 7; i++)
        // + width/14 to center text between lines
        text(WEEKDAYS[i], (i * width/7) + width/14, -(DAY_NAME_BOX_HEIGHT/2) - 2); 
    pop();
    strokeWeight(1);
    // Starts at 1 so it doesn't draw a line over the day name line
    float y;
    for (int i = 1; i < 6; i++)
    {
      y = i * ((height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT))/5);
      line(0, y, width, y);
    }
  pop();
  
  int day_acc = 0;
  push();
    translate(10, MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT + 10);
    boolean initial = true;
    float x_translate_added = 0;  // This is to accurately realign the numbers when the y-axis moves down
    for (int y_ = 0; y_ < 5; y_++)
    {
      for (int x_ = 0; x_ < 7; x_++)
      {
        // Sets first day of month number to proper weekday
        if (initial)
        {
          if (WEEKDAYS[x_] != FIRST_DAY_OF_MONTH_NAME)
          {
            // Greying out days before month start
            push();
              stroke(1);
              translate(-10, -9);
              fill(320);
              rect(0, 0, width/7, ((height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT))/5));
            pop();
        
            translate(width/7, 0);
            x_translate_added += width/7;
            continue;
          }
          else
          {
            initial = false;
          }
        }
        // Actually writing the number
        textAlign(LEFT, CENTER);
        textSize(12);
        noStroke();
        fill(0);
        text(String.valueOf(day_acc), 0, 0);
        
        // Keeping tabs of accumulation
        day_acc++;
        if (day_acc > DAYS_IN_MONTH)
        {
            // Greying out days after month ends
            push();
              stroke(1);
              translate(-10, -10);
              fill(320);
              // No clue why the +10 is needed on the end width of the square
              rect(0, 0, width/7 + 10, ((height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT))/5));
            pop();
        }
          
        translate(width/7, 0);
        x_translate_added += width/7;
      }
      translate(-x_translate_added, ((height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT))/5));
      x_translate_added = 0;
      
    }
  pop();
  
  //OUTLINE LINES
  stroke(0);
  strokeWeight(2);
  int line_buffer = 1;
  line(line_buffer, MONTH_BOX_HEIGHT, line_buffer, height - line_buffer);  // LEFT
  line(width - line_buffer, MONTH_BOX_HEIGHT, width - line_buffer, height - line_buffer);  // RIGHT
  line(line_buffer, height - line_buffer, width - line_buffer, height - line_buffer);  // BOTTOM
  
  exit();
}
