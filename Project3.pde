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
PImage imageSnake;
PImage imageSnake2;
PImage imageSnake3;
PImage imageSnake4;
PImage imageLose;
PImage imageWin;
float rectX = 681; //collision rectangle
float rectY = 333;
float rectWidth = 200;
float rectHeight = 300;
int x, y; //for collision circle around a snake

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
SoundFile file;
String audio= "NarutoThemeSong.mp3";
String path;

//---------------------------------------------

//add sound
void setup(){
  size(800,521);
  printArray(Serial.list());
  myPort  =  new Serial (this, Serial.list()[serialIndex],  115200);
  imageNaruto= loadImage("naruto.PNG"); //loads images
  imageDay= loadImage("daybg.JPG");
  imageNight=loadImage("nightbg.jpg");
  imageNarutoSauske=loadImage("narutoSauske.png");
  imageNarutoSakura= loadImage("narutoSakura.png");
  imageOrochi= loadImage("orochi.PNG");
  imageSnake= loadImage("snake.png");
  imageSnake2= loadImage("snake.png");
  imageSnake3= loadImage("snake.png");
  imageSnake4= loadImage("snake.png");
  imageWin= loadImage("winBg.jpg");
  imageLose=loadImage("loseBg.jpg");
  path=sketchPath(audio); //loads audio
  file=new SoundFile(this, path);
  file.play();
  font=createFont("Brush Script MT", 55);
  x=width/2;
  y=height/2; //sets circle
  
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
  }
}

//---------------------------------------------

void draw(){
  if(state==stateHome){ //if the state is = to stateHome (which it is because both =0)
    homeScreen(); //then the home screen is displayed
  }else if(state==statePlay){ //when the state is statePlay, it calls all functions below
     checkSerial();
    //state=stateLose;
     drawBackground();
     drawHealthBar();
     drawOrochi();
     drawSnakes();
     pickTeam();
     gameOver();
  }else if(state==stateWin){ //when the state is stateWin the win screen appears
    winScreen();
    drawPlayAgain();
    drawReturnHome();
  }else if(state==stateLose){ //when the state is stateLose the lose screen appears
    loseScreen();
    drawPlayAgain();
    drawReturnHome();
  }
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
  brightness(int(map(ldrValue, 0, 3000, 0, 255))); //maps LDR
  if(ldrValue==0){ //if the brightness is 0, then the night background is shown
    background(imageNight);
  }else{ //if brightness is above 0 then the day background is displayed.
    background(imageDay);
  }
}

//---------------------------------------------

void drawOrochi(){
  image(imageOrochi, 500,250, width/2, height/2); //draws out the opponnent 
}
 
//---------------------------------------------
 
 void drawSnakes(){
   image(imageSnake,50,250, width/2, height/2+100);
   image(imageSnake2, 400, 300, width/2, height/2+100);
   image(imageSnake3, 300, 80,width/2, height/2+100);
   image(imageSnake4, 35, 300, width/2, height/2+100);

}
 
//---------------------------------------------
 
void pickTeam(){
  if(switchValue==1){ //if the button is held down teammate is Sakura
    image(imageNarutoSakura, mouseX, mouseY, 300, 300); 
  }else{ //if button is not pressed then Sauske appears
    image(imageNarutoSauske, mouseX, mouseY, 300, 300);
  }
}

//---------------------------------------------

void winScreen(){ 
  background(imageWin);
  textFont(font);
  textSize(85);
  fill(243,3,3); //if collision is detected between the players and opponent then this screen is displayed
  text("YOU WIN!",width/2-50, height/2-150);
  image(imageNarutoSauske, 300,150, 400,400);
  image(imageNarutoSakura, 50,0, 400,400);
  healthTimer.start(); //restarts timer
}

//---------------------------------------------

void loseScreen(){
  background(imageLose);
  image(imageOrochi,200,150, 400,400);
  textFont(font); //if collision is detected between the players and the snake or time runs out this screen is displayed
  textSize(85);
  fill(243,3,3);
  text("YOU LOSE!",width/2-100, height/2-50);
  healthTimer.start(); //restarts timer
}

//---------------------------------------------

void gameOver(){
  noFill();
  noStroke();
  rect(rectX, rectY, rectWidth, rectHeight); //opponent's rectangle, if the two rectangles collide then the stateWin is displayed
  if(mouseX+mouseRectWidth> rectX && mouseX< rectX + rectWidth && mouseY+ rectHeight > rectY&& mouseY < rectY +rectHeight){
   state=stateWin;
  }else if(dist(x,y,mouseX,mouseY)<=50){ //if the mouse is in the radius of the circle stateLose is displayed
    state=stateLose;
  noFill();
  rect(mouseX, mouseY, mouseRectWidth, mouseRectHeight); //Naruto rectangle
  ellipse(x,y,100,100); //snake's circle
}
}

//---------------------------------------------

void drawPlayAgain(){
  textFont(font);
  textSize(30);
  fill(0);
  rect(50,55,150,50);
  fill(255);
  text("Play Again!", 65,95); //start button, when the mouse clicks where the rectangle is, the state will change to the play screen
  if(mousePressed){
    if(mouseX>50 && mouseX <50+150 && mouseY>55 && mouseY <55+50){
      state=statePlay;
    }
  }
}

//---------------------------------------------

void drawReturnHome(){
  textFont(font);
  textSize(20);
  fill(0);
  rect(70,400,150,50);
  fill(255);
  text("Return to Home Screen!", 62,420); //start button, when the mouse clicks where the rectangle is, the state will change to the home screen
  if(mousePressed){
    if(mouseX>70 && mouseX <70+150 && mouseY>55 && mouseY <55+400){
      state=stateHome;
    }
  }
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
    state=stateLose;
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
