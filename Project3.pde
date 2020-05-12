import processing.sound.*;
// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    
// Initializing a vairable named 'myPort' for serial communication
Serial myPort;  
String portName= "/dev/tty.SLAB_USBtoUART";
// Data coming in from the data fields
String [] data;
int switchValue = 0;    // index from data fields
int ldrValue = 0;
// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex = 27;
int minldrValue = 0;
int maxldrValue = 4095;    // will be 1023 on other systems
PImage imageNaruto;
//PImage imageSauske;
//PImage imageSakura;
PImage imageNight;
PImage imageDay;
PFont font;
PImage imageOrochi;
PImage imageNarutoSauske;
PImage imageNarutoSakura;
float rectX = 681; //collision rectangle
float rectY = 333;
float rectWidth = 200;
float rectHeight = 300;

float mouseRectWidth = 300; //rectangle around Naruto
float mouseRectHeight = 200;

PFont displayFont;
Timer healthTimer; //calls Timer class
int healthTimerMS = 15000;  // how long in MS the timer will be
int hMargin = 100;

float progressBarWidth = 400;    // change according to the width in setup()
float progressBarHeight = 20;
int state=0;
int stateHome=0;
int statePlay=1;
int stateWin=2;
int stateLose=3;

//---------------------------------------------

//add sound
void setup(){
  size(800,521);
  printArray(Serial.list());
  myPort  =  new Serial (this, Serial.list()[serialIndex],  115200);
  imageNaruto= loadImage("naruto.PNG");
  //imageSauske= loadImage("sauske.PNG");
  //imageSakura=loadImage("sakura.PNG");
  imageDay= loadImage("daybg.JPG");
  imageNight=loadImage("nightbg.jpg");
  imageNarutoSauske=loadImage("narutoSauske.png");
  imageNarutoSakura= loadImage("narutoSakura.png");
  imageOrochi= loadImage("stickfigureO.png");
  font=createFont("Brush Script MT", 55);
  
  frameRate(15);
  rectMode(CORNER);
  textAlign(LEFT);
  displayFont = createFont("Brush Script MT", 32);
  // adjust progress bar length to width of sceeen
  progressBarWidth = width - (hMargin *2);
  // Allocate the timer
  healthTimer = new Timer(healthTimerMS);    //  second time
  // start the timer. Every 1/2 second, it will do something
  healthTimer.start();
  // check to see if timer is expired, then restart timer
  if( healthTimer.expired() ){
    healthTimer.start();
    //state=stateLose;
  }
}

//---------------------------------------------

void draw(){
/*  textSize(20);
  println(mouseX,mouseY);*/
  if(state==stateHome){
    homeScreen();
  }else if(state==statePlay){
     checkSerial();
     drawBackground();
     drawHealthBar();
     drawOrochi();
     pickTeam();
     gameOver();
  }else if(state==stateWin){
    winScreen();
  }/*else if(state==stateLose){
    loseScreen();
  }*/
}

//---------------------------------------------

// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    print(inBuffer);
    // This removes the end-of-line from the string AND casts it to an integer
    inBuffer = (trim(inBuffer));
    data = split(inBuffer, ',');
    // do an error check here?
    switchValue = int(data[0]);
    ldrValue = int(data[2]);
  }
} 

//---------------------------------------------

void homeScreen(){ //initializes to this screen
  background(255);
  image(imageNaruto, 200,150, 400,400);
  textFont(font);
  fill(255,114,44);
  text("Welcome to Naruto's Battle!", 143, 200);
  fill(0);
  rect(50,55,150,50);
  fill(255);
  text("Start!", 65,95); //start button, when the mouse clicks whrere the rectangle is, the state will change to the play screen
  if(mousePressed){
    if(mouseX>50 && mouseX <50+150 && mouseY>55 && mouseY <55+50){
      state=statePlay;
    }
  }
}
  
//--------------------------------------------- 
  
void drawBackground(){ //background for statePlay
  float brightness= 0;
  brightness(int(map(ldrValue, 0, 3000, 0, 255))); 
  if(ldrValue==0){ //if the brightness is 0, then the night background is shown
    background(imageNight);
  }else{ //if brightness is above 0 then the day background is displayed.
    background(imageDay);
  }
}

//---------------------------------------------

void drawOrochi(){
  image(imageOrochi, 500,250, width/2, height/2); //replace with real drawing
}
 
//---------------------------------------------
 
void pickTeam(){
  if(switchValue==1){ //if the button is held down teammate is Sakura
    image(imageNarutoSakura, mouseX, mouseY, 300, 300); //use actual image dimensions, //randomization
  }else{ //if button is not pressed then Sauske appears
    image(imageNarutoSauske, mouseX, mouseY, 300, 300);
  }
}

//---------------------------------------------

void winScreen(){ 
  background(255);
  textFont(font);
  fill(255,114,44); //if collision is detected then this screen is displayed
  text("YOU WIN!",width/2+100, height/2);
  image(imageNarutoSauske, 300,150, 400,400);
  image(imageNarutoSakura, 50,0, 400,400);
 /* fill(0);
  rect(50,400,300,100);
  fill(255, 114,44);
  text("Play Again!", 65,460);
  if(mousePressed){
    if(mouseX>50 && mouseX <50+300 && mouseY>400 && mouseY <400+100){
      state=statePlay; 
    }
  }*/
}

//---------------------------------------------

/*void loseScreen(){
  background(255);
  image(imageOrochi,200,150, 400,400);
  textFont(font);
  fill(255,114,44);
  text("YOU WIN!",width/2-100, height/2);
}*/

//---------------------------------------------

void gameOver(){
  noFill();
  noStroke();
  rect(rectX, rectY, rectWidth, rectHeight); //opponent's rectangle, if the two rectangles collide then the stateWin is displayed
  if(mouseX+mouseRectWidth> rectX && mouseX< rectX + rectWidth && mouseY+ rectHeight > rectY&& mouseY < rectY +rectHeight){
   state=stateWin;
  }
  noFill();
  rect(mouseX, mouseY, mouseRectWidth, mouseRectHeight); //Naruto rectangle
}


//---------------------------------------------

void drawHealthBar(){
   // SHOW REMAING TIME
  fill(255);
  textSize(32);
  textFont(font);

  // make it into seconds with a single decimal point — these two lines seem to do the proper formatt
  float secondsDisplay = healthTimer.getRemainingTime()/100;
  secondsDisplay = secondsDisplay/10;
  if (secondsDisplay==0){ //when the time is 0 then the losing satement is posted
    textFont(font);
    fill(255,114,44);
    text("YOU LOSE!",width/2-100, height/2);
  }
  text("Health: " + str(secondsDisplay), hMargin, 120 ); 
 // DISPLAY PROGRESS BAR BASED ON PERCENTAGE
    float elapsedPercentage = healthTimer.getPercentageElapsed();
    println( "Elapsed % = " + elapsedPercentage ); 
    // draw fill
    fill( 255,114,44);
    rect( hMargin, 120, progressBarWidth * elapsedPercentage, progressBarHeight);
    // drawOutine
    noFill();
    stroke(255);
    strokeWeight(1);
    rect( hMargin, 120, progressBarWidth, progressBarHeight);
}
