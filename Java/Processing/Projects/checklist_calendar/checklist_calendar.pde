import java.util.*;  // For Date
import java.time.*;  // For LocalDate
import processing.pdf.*;  // To convert to PDF

// TODO: Seperate grey boxes into their own function
  // Implement interate through month as ultimate helper function

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
int FIRST_DAY_OF_MONTH_COLUMN;
int DAYS_IN_MONTH;

// CALENDAR ALIGNMENTS
float MONTH_BOX_HEIGHT;
float DAY_NAME_BOX_HEIGHT = 25;

// CALENDAR GRID INFO
int AMOUNT_OF_ROWS;


void setup()
{
  size(825, 638);
  //size(825, 638, PDF, "calendar_test.pdf");
  surface.setLocation(50, 50);
  colorMode(HSB, 360, 100, 100, 100);
  textAlign(CENTER, CENTER);
  strokeCap(SQUARE);
  background(360);
  
  // CALENDAR ALIGNMENT
  MONTH_BOX_HEIGHT = height/6;
  
  // DATE STUFF
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
  
  // GRID STUFF
  AMOUNT_OF_ROWS = 5;
  
  FIRST_DAY_OF_MONTH_COLUMN = 0;
  while (WEEKDAYS[FIRST_DAY_OF_MONTH_COLUMN] != FIRST_DAY_OF_MONTH_NAME)
    FIRST_DAY_OF_MONTH_COLUMN++;
  
  // Adjusting rows if days don't fit into 7x5 grid
  int DAYS_FITTING_INTO_7X5 = 35 - FIRST_DAY_OF_MONTH_COLUMN;
  if (DAYS_FITTING_INTO_7X5 < DAYS_IN_MONTH)
    AMOUNT_OF_ROWS = 6;
}

void draw()
{
  month_box();
  grid_lines();
  weekday_names();
  day_numbers();
  daily_text();
  calendar_outline();
  
  //exit();
}

void month_box()
{
  // Month name "text box"
  push();
    noStroke();
    fill(22, 100, 100);
    rect(0, 0, width, MONTH_BOX_HEIGHT);
    fill(360);
    textSize(60);
    text(MONTH_AND_YEAR, width/2, MONTH_BOX_HEIGHT/2.3);
  pop();
}

void grid_lines()
{
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
    translate(0, DAY_NAME_BOX_HEIGHT);
    line(0, 0, width, 0);

    // Starts at 1 so it doesn't draw a line over the day name line
    float y;
    for (int i = 1; i < AMOUNT_OF_ROWS + 1; i++)
    {
      y = i * ((height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT))/AMOUNT_OF_ROWS);
      line(0, y, width, y);
    }
  pop();
}

void weekday_names()
{
  push();
    translate(0, MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT);
    noStroke();
    fill(0);
    textSize(15);
    for (int i = 0; i < 7; i++)
      // + width/14 to center text between lines
      text(WEEKDAYS[i], (i * width/7) + width/14, -(DAY_NAME_BOX_HEIGHT/2) - 2); 
  pop();
}

void day_numbers()
{
  int day_acc = 1;
  int x_buffer = 5;
  int y_buffer = 10;
  push();
    translate(x_buffer, MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT + y_buffer);
    boolean initial = true;
    float x_translate_added = 0;  // This is to accurately realign the numbers when the y-axis moves down
    for (int y_ = 0; y_ < AMOUNT_OF_ROWS; y_++)
    {
      for (int x_ = 0; x_ < 7; x_++)
      {
        // Sets first day of month number to proper weekday
        if (initial)
        {
          if (WEEKDAYS[x_] != FIRST_DAY_OF_MONTH_NAME)
          {
            // Greying out days before month start
            grey_box(-x_buffer, -y_buffer, 0);
        
            // Moving onto next day
            translate(width/7, 0);
            x_translate_added += width/7;
            continue;
          }
          else
          {
            // Stopping grey boxes, starting day numbers
            initial = false;
          }
        }
        // Actually writing the number
        textAlign(LEFT, CENTER);
        textSize(12);
        noStroke();
        fill(0);
        text(String.valueOf(day_acc), 0, 0);
        
        if (day_acc > DAYS_IN_MONTH)
        {
            // Greying out days after month ends
            // No clue why the +10 is needed on the end width of the square
            grey_box(-x_buffer, -y_buffer, 10);
        }
        // Keeping tabs of accumulation
        day_acc++;
          
        // Moving onto next day
        translate(width/7, 0);
        x_translate_added += width/7;
      }
      // Moving onto next week
      translate(-x_translate_added, ((height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT))/AMOUNT_OF_ROWS));
      x_translate_added = 0;  // Resetting x to beginning of week
    }
  pop();
}

void iterate_through_month(String doing)
{
  int day_acc = 1;
  push();  
    float x_translate_added = 0;  // This is to accurately realignwhen the y-axis moves down
    for (int y_ = 0; y_ < AMOUNT_OF_ROWS; y_++)
    {
      for (int x_ = 0; x_ < 7; x_++)
      {
        number_display(day_acc, x_);
        
        // Moving onto next day
        day_acc++;
        translate(width/7, 0);
        x_translate_added += width/7;
      }
      // Moving onto next week
      translate(-x_translate_added, ((height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT))/AMOUNT_OF_ROWS));
      x_translate_added = 0;  // Resetting x to beginning of week
    }
  pop();
}

void number_display(int day_num, int weekday_iterator)
{
  // TODO: Make greying out boxes its own function
  
  int x_buffer = 5;
  int y_buffer = 10;
  
  push();
    translate(x_buffer, MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT + y_buffer);
    
    boolean initial = true;
    // Sets first day of month number to proper weekday
        if (initial)
        {
          if (WEEKDAYS[weekday_iterator] != FIRST_DAY_OF_MONTH_NAME)
          {
            // Greying out days before month start
            grey_box(-x_buffer, -y_buffer, 0);
        
            // Moving onto next day
            translate(width/7, 0);
            x_translate_added += width/7;
            continue;
          }
          else
          {
            // Stopping grey boxes, starting day numbers
            initial = false;
          }
        }
        // Actually writing the number
        textAlign(LEFT, CENTER);
        textSize(12);
        noStroke();
        fill(0);
        text(String.valueOf(day_acc), 0, 0);
        
        if (day_acc > DAYS_IN_MONTH)
        {
            // Greying out days after month ends
            // No clue why the +10 is needed on the end width of the square
            grey_box(-x_buffer, -y_buffer, 10);
        }
  pop();
}

void grey_box(int x_translate, int y_translate, int x_additional)
{
  push();
    stroke(0);
    translate(x_translate, y_translate);
    fill(320);
    rect(0, 0, width/7 + x_additional, ((height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT))/AMOUNT_OF_ROWS));
  pop();
}

void calendar_outline()
{
  push();
    stroke(0);
    strokeWeight(2);
    int line_buffer = 1;  // For visibility
    line(line_buffer, MONTH_BOX_HEIGHT, line_buffer, height - line_buffer);  // LEFT
    line(width - line_buffer, MONTH_BOX_HEIGHT, width - line_buffer, height - line_buffer);  // RIGHT
    line(line_buffer, height - line_buffer, width - line_buffer, height - line_buffer);  // BOTTOM
  pop();
}

void daily_text()
{
  
}

void bullet_point(float x, float y, int size)
{
  push();
    stroke(0);
    square(x, y, size);
  pop();
}
