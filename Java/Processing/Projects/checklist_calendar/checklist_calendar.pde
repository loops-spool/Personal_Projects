import java.util.*;  // For Date
import java.time.*;  // For LocalDate
import processing.pdf.*;  // To convert to PDF
import geomerative.*;  // For text outline

// PDF Switcher
boolean is_PDF = true;

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
float ROW_SIZE;
float COL_SIZE;
float DAY_GRID_STROKE_WEIGHT = 2;  
int CALENDAR_BORDER_WEIGHT = 4;
int CALENDAR_BORDER_BUFFER = floor(CALENDAR_BORDER_WEIGHT/2);  // So strokeWeight lines up with pixels inside border to align all squares the same
int DAY_NAME_OUTLINE_WEIGHT = 3;
int DAY_NAME_OUTLINE_BUFFER = floor(DAY_NAME_OUTLINE_WEIGHT/2);
daily_box_class[] day_boxes;

// FONTS
int MONTH_TEXT_SIZE = 60;
RFont default_month_font;
PFont month_font;
PFont body_text;
PFont body_text_bold;

// GRAPHICS
PGraphics month_banner;


void settings()
{
  // TODO: Test if the below is even true
  //////////////////////////////    WARNING    //////////////////////////////
  // Sizes pretty much have to remain here for rows/cols to display evenly
    // height 600 is divisible by 4, 5, and 6 (all possible row amounts) so will always have rounded int row lines
  
  if (is_PDF)
  {
    size(780, 600, PDF, "calendar_test.pdf");
  }
  else
  {
    size(780, 600);
    noLoop();
  }
}

void setup()
{
  surface.setLocation(50, 50);
  colorMode(HSB, 360, 100, 100, 100);
  textAlign(CENTER, CENTER);
  strokeCap(SQUARE);
  background(360);
  
  // Uncomment to view available fonts
  //String[] fontList = PFont.list();
  //printArray(fontList);
  RG.init(this);  // Initializes geomerative stuff
  default_month_font = new RFont("data\\CASTELAR.TTF", 60, RFont.CENTER);
  month_font = createFont("Castellar", 60);
  body_text = createFont("Century Schoolbook", 12);
  body_text_bold = createFont("Century Schoolbook Bold", 12);
  
  // CALENDAR ALIGNMENT
  // TODO: See if the below is needed
  //////////////////////////////    WARNING    //////////////////////////////
  // -7 here to keep (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT + DAY_NAME_OUTLINE_BUFFER + CALENDAR_BORDER_BUFFER) == 120
    // 120 is a multiple of 60 (divisible by 4, 5, and 6 (all possible row amounts))
      // So rows will always fall on rounded integers
  // If adjusting ANY of the variables above, adjust this so the sum will == 120
  MONTH_BOX_HEIGHT = height/6 - 7;
    // TODO: Adjust with border weight
  
  // DATE STUFF
  CURRENT_DATE = new Date();
  LOCAL_DATE = CURRENT_DATE.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
  //LOCAL_DATE = LOCAL_DATE.plusMonths(5);
  YEAR = LOCAL_DATE.getYear();
  MONTH = LOCAL_DATE.getMonthValue();
  DAY = LOCAL_DATE.getDayOfMonth();
  MONTH_NAME = LOCAL_DATE.getMonth().toString();
  FIRST_DAY_OF_MONTH_NAME = LOCAL_DATE.minusDays(DAY-1).getDayOfWeek().toString();
  MONTH_AND_YEAR = MONTH_NAME + " " + YEAR;
  DAYS_IN_MONTH = LOCAL_DATE.lengthOfMonth();
  
  // GRID STUFF
  AMOUNT_OF_ROWS = 5;
  
  // Finding what column month starts in
  FIRST_DAY_OF_MONTH_COLUMN = 0;
  while (WEEKDAYS[FIRST_DAY_OF_MONTH_COLUMN] != FIRST_DAY_OF_MONTH_NAME)
    FIRST_DAY_OF_MONTH_COLUMN++;
  
  // Adding a row if days don't fit into 7x5 grid
    // If longer month starts later in the week
  int DAYS_FITTING_INTO_7X5 = 35 - FIRST_DAY_OF_MONTH_COLUMN;
  if (DAYS_FITTING_INTO_7X5 < DAYS_IN_MONTH)
    AMOUNT_OF_ROWS = 6;
  
  // If February starts on a Monday and it isn't a leap year it only needs 4 rows
  if ((DAYS_IN_MONTH == 28) && (FIRST_DAY_OF_MONTH_COLUMN == 0))
    AMOUNT_OF_ROWS = 4;

  // - DAY_GRID_STROKE_WEIGHT/2 at the end to blend in the last row bottom day grid line with the border
  ROW_SIZE = height - (MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT + DAY_NAME_OUTLINE_BUFFER + CALENDAR_BORDER_WEIGHT - DAY_GRID_STROKE_WEIGHT/2);
  ROW_SIZE /= AMOUNT_OF_ROWS;
  
  // + (2 * DAY_ GRID_STROKE_WEIGHT/2) because the stroke occurs outside where the line for the squares is drawn
  COL_SIZE = (width - (2 * CALENDAR_BORDER_WEIGHT) + (2 * DAY_GRID_STROKE_WEIGHT/2))/7;
  
  // Initializing daily squares
  int square_amount = AMOUNT_OF_ROWS * 7;
  day_boxes = new daily_box_class[square_amount];
  for (int i = 0; i < square_amount; i++)
    day_boxes[i] = new daily_box_class();
}

void draw()
{
  month_art();
  month_art_cutoff();
  draw_daily_boxes();
  weekday_names();
  calendar_outline();
    
  if (is_PDF)
    exit();
}

void month_art_cutoff()
{
  // White box covering any overlap from the monthly art header
  push();
    noStroke();
    fill(360);
    rect(0, MONTH_BOX_HEIGHT, width, height);
  pop();
}

void weekday_names()
{
  // TODO: Make each their own textbox
  textFont(body_text_bold);
  
  push();
    // Border lines
    strokeWeight(DAY_NAME_OUTLINE_WEIGHT);
    translate(0, MONTH_BOX_HEIGHT);
    line(0, 0, width, 0);
    line(0, DAY_NAME_BOX_HEIGHT, width, DAY_NAME_BOX_HEIGHT);
    
    // Actual day names 
    textFont(body_text_bold);
    textSize(14);
    fill(0);

    float x;
    for (int i = 0; i < 7; i++)
    {
      x = CALENDAR_BORDER_WEIGHT - DAY_GRID_STROKE_WEIGHT/2 + (i * COL_SIZE);
      strokeWeight(DAY_GRID_STROKE_WEIGHT);
      line(x, 0, x, DAY_NAME_BOX_HEIGHT);
      // + width/14 to center text between lines
      text(WEEKDAYS[i], x + COL_SIZE/2, (DAY_NAME_BOX_HEIGHT/2) - 2); 
    }
  pop();
}

void draw_daily_boxes()
{
  int square_acc = 0;
  int day_acc = 0;
  
  // If month starts on a Monday (first square), make it day 1
      // So square doesn't get greyed out & day number shows as 1
        // Since normally isn't accumulated until after function calls
  if (FIRST_DAY_OF_MONTH_COLUMN == 0)
    day_acc++;
    
  push();
    // NOTE: Factor in that a rect with stroke will apply ONLY half the stroke in the upper left hand corner
      // Hence the stroke_weight adjuster at the end of the x & y translate
    translate(CALENDAR_BORDER_WEIGHT - DAY_GRID_STROKE_WEIGHT/2, MONTH_BOX_HEIGHT + DAY_NAME_BOX_HEIGHT + DAY_NAME_OUTLINE_BUFFER);

    for (int y = 0; y < AMOUNT_OF_ROWS; y++)
    {
      for (int x = 0; x < 7; x++)
      {
        day_boxes[square_acc].display(day_acc);
        
        // Moving onto next day
        square_acc++;
        if (square_acc >= FIRST_DAY_OF_MONTH_COLUMN)
          day_acc++;
          
        translate(COL_SIZE, 0);
      }
      // Moving onto next week
      translate(-(COL_SIZE * 7), ROW_SIZE);
    }
  pop();
}

void calendar_outline()
{
  push();
    stroke(0);
    strokeWeight(CALENDAR_BORDER_WEIGHT);
    line(CALENDAR_BORDER_BUFFER, 0, CALENDAR_BORDER_BUFFER, height);  // LEFT
    line(width - CALENDAR_BORDER_BUFFER, 0, width - CALENDAR_BORDER_BUFFER, height);  // RIGHT
    line(0, CALENDAR_BORDER_BUFFER, width, CALENDAR_BORDER_BUFFER);  // TOP
    line(0, height - CALENDAR_BORDER_BUFFER, width, height - CALENDAR_BORDER_BUFFER);  // BOTTOM
  pop();
}

void draw_text(font_class Font)
{
  push();
    if (Font.is_bolded)
      bold_font(Font);
    else
    {
      Font.set_features();
      Font.display();
    }
  pop();
}

void bold_font(font_class Font)
{
  push();
    Font.set_features();
    // "Bolds" the font a little -- since theres no bold versions of some fonts
    float x_shift_divisor = 5;  // To utilize i as coordinate, small shifts in x
    for (float i = 0; i < Font.bold_weight/x_shift_divisor; i += 1/x_shift_divisor)
    {
      translate(i, 0);
      Font.display();
    }
  pop();
}

/** 
TODO: Text effects: 
  - 3D gradually increasing font size
  - Text Fade in/out
  + See what geomerative can do
  
  Maybe make its own tab?
**/ 
