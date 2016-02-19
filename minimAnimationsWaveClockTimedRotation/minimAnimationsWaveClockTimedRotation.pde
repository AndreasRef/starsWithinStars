//Rough test to test integration with MIDI Clock
//Issues: Sometimes BPMvalues drops to half...


import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus

import javax.sound.midi.MidiMessage; //This is important because in this case we will use the MidiMessage class

import controlP5.*;
ControlP5 cp5;

import ddf.minim.*;
import ddf.minim.analysis.*;

// Minim********************************************************************************
Minim       minim;
AudioPlayer myAudio;
FFT         myAudioFFT;


boolean     showVisualizer   = true;

int         myAudioRange     = 11;
int         myAudioMax       = 100;

float       myAudioAmp       = 40.0;
float       myAudioIndex     = 0.2;
float       myAudioIndexAmp  = myAudioIndex;
float       myAudioIndexStep = 0.35;

float[]     myAudioData      = new float[myAudioRange];
// ************************************************************************************

float theta = 0.0;
float osc;

float starScale = 1;

int starOffest = 40;

int radius1 = 250;
float starDepth = 0.1;
float centerFreeSpace = 0;
int starEdges = 5;
float starDecrease = 0.01;
float rotationAmplitude = 5;
float rotationSpeed = 0.05;
int rotationPeriod = 5000;


float periodVis;
long currentTime;
int adjustTime;


float globalEasing = 0.1; //The higher the number, the faster the movement (less easing)
float xstarDepth; //variable used for easing starDepth
float xradius1;



// ************************************************************************************
int size = 50;
int count;
int prevCount;

long period = 1000000000 / (120 / 60);
long lastbeat = 0;
long lastTap = 0;

float bpm;
int bg;
int beat;

void setup() {
  //size(1200, 900);
  fullScreen();
  //size(900, 600);
  noStroke();
  minim   = new Minim(this);
  myAudio = minim.loadFile("HECQ_With_Angels_Trifonic_Remix_cut.wav");
  myAudio.loop();

  myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
  myAudioFFT.linAverages(myAudioRange);
  myAudioFFT.window(FFT.GAUSS);



  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 0, 3); // Create a new MidiBus. Make sure the input is set to match the MIDI channel that WaveClock is outputting to
  lastbeat = millis();


  cp5 = new ControlP5(this);
  cp5.addSlider("radius1", 0, height/2).linebreak();
  cp5.addSlider("centerFreeSpace", 0.0, 1.0).linebreak();
  //cp5.addSlider("starOfset",10,400).linebreak();
  cp5.addSlider("starDecrease", 0.01, 0.50).linebreak();
  cp5.addSlider("starDepth", 0.01, 1.0).linebreak();
  cp5.addSlider("starEdges", 2, 16).linebreak();
  cp5.addSlider("rotationAmplitude", 0, 10).linebreak();
  cp5.addSlider("rotationSpeed", 0.00, 0.1).linebreak();
  cp5.addSlider("globalEasing", 0.01, 0.4).linebreak();
  cp5.addSlider("rotationPeriod", 500, 10000).linebreak();

  cp5.addSlider("periodVis", -1, 1).linebreak();
}

void draw() {
  //background(#202020);
  background(0);
  myAudioFFT.forward(myAudio.mix);
  myAudioDataUpdate();


  int time = millis();


  osc = rotationAmplitude*cos(TWO_PI *(time+adjustTime)/rotationPeriod);  
  cp5.getController("periodVis").setValue(osc/rotationAmplitude);

  if (keyPressed) {
    adjustTime = rotationPeriod/2 - time;
  }



  // Easing starDepth (controlled by snare)
  starDepth =myAudioData[3]/60;
  float targetstarDepth = starDepth;
  float dxstarDepth = targetstarDepth - xstarDepth;
  xstarDepth+=dxstarDepth*globalEasing;
  cp5.getController("starDepth").setValue(xstarDepth);

  // Easing radius1 (controlled by base)
  radius1 = int(myAudioData[0]*height/100);
  float targetRadius1 = radius1;
  float dxradius1 = targetRadius1 - xradius1;
  xradius1+=dxradius1*globalEasing;
  cp5.getController("radius1").setValue(xradius1);


  //StarEdges (controlled by beat)
  //cp5.getController("starEdges").setValue((beat%24)/2 +1);


  //rotationAmplitude (controlled by beat)
  //cp5.getController("rotationAmplitude").setValue((beat%10));
  
  //rotationPeriod (controlled by BPM)
  cp5.getController("rotationPeriod").setValue((480000/150)*2);
  
  ////////////////

 // period = 10;

  //osc = (sin(theta/period)*rotationAmplitude);   

  pushMatrix();
  translate(width/2, height/2);

  int internalStars = int(((radius1*2-radius1*2*centerFreeSpace)+1)/(starDecrease*radius1*2))+1;

  star(0, 0, radius1, 1 - starDepth, starEdges, internalStars, starDecrease); //1-starDepth as a test
  popMatrix();

  theta += rotationSpeed;
  starScale = 1;


  if (count%(24) == 0 && (prevCount !=count)) { //Try to avoid calling this function two times with the same count (something to do with framerate perhaps)?
    calculateBPM();
  }

  pushStyle();
  fill(255);
  //rect(size*(beat%4), 320, size, size);
  text("BPM is " + bpm, 100, 300);
  popStyle();

  if (showVisualizer) myAudioDataWidget();
}

void star(float x, float y, float radius1, float starDepth, int starEdges, int internalStars, float starDecrease) {
  float angle = TWO_PI / starEdges;
  float halfAngle = angle/2.0;

  //for (int i = internalStars; i > 0; i--) {
  for (int i = 0; i < internalStars; i++) {
    color c;
    if (i%2 ==0) {
      c=#FFFFFF;
    } else {
      c=#000000;
    }
    fill(c);

    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * (1- starDepth)* radius1;
      float sy = y + sin(a) * (1- starDepth)* radius1;
      vertex(sx, sy);
      sx = x + cos(a+halfAngle) * radius1;
      sy = y + sin(a+halfAngle) * radius1;
      vertex(sx, sy);
      //rotate(TWO_PI/64);
    }

    rotate(radians(osc));

    starScale -= starDecrease;
    scale(starScale);

    //rotate(radians(osc));

    endShape(CLOSE);
  }
  //rotate(radians(osc));
}

void myAudioDataUpdate() {
  for (int i = 0; i < myAudioRange; ++i) {
    float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmp) * myAudioIndexAmp;
    float tempIndexCon = constrain(tempIndexAvg, 0, myAudioMax);
    myAudioData[i]     = tempIndexCon;
    myAudioIndexAmp+=myAudioIndexStep;
  }
  myAudioIndexAmp = myAudioIndex;
}

void myAudioDataWidget() {
  // noLights();
  // hint(DISABLE_DEPTH_TEST);
  noStroke(); 
  fill(0, 200); 
  //rect(0, height-112, width, 102);

  for (int i = 0; i < myAudioRange; ++i) {
    if     (i==0) fill(#237D26); // base  / subitem 0
    else if (i==3) fill(#80C41C); // snare / subitem 3
    else          fill(#CCCCCC); // others

    rect(10 + (i*5), (height-myAudioData[i])-11, 4, myAudioData[i]);
  }
  // hint(ENABLE_DEPTH_TEST);
}

void stop() {
  myAudio.close();
  minim.stop();  
  super.stop();
}



void midiMessage(MidiMessage message) {
  if (message.getStatus() == 0xF8) {//0xF8 is the status byte for TIMING_CLOCK
    count++; //Count the number of status bytes (F8), that is sent every 24 times per quarter note. Perhaps there is a better method?
  }
}

void keyPressed() {
  count =0; //Used for getting the 1 beat right
  beat = 0;
}


void calculateBPM() {
  //println("count: " + count);
  prevCount = count;
  if (lastTap != 0) { // if we have a last tap time
    period = millis() - lastTap; // calculate how long it's been and set the period
    // println("Period is "+period);

    //float periodS = period/1000.0;
    if (period > 100) { //Old debug method (should perhaps die?)
      bpm = 60/(period/1000.0); 
      //println("BPM is " + bpm);
      bg = 0;
    } else {
      bg = 255;
    }
  } else {
    println("First tap");
  }
  lastTap = millis();
  beat++;
}