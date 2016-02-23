//Simple FFT analysis of mic input or dragged soundfile controls part of the animation

//To do: Perhaps a function that calculates the peaks/ energy in the song and automatically adjusts the freqEnergies?


//Sound
var mic, soundFile;
var currentSource = 'Broke For Free - As Colorful As Ever';
var fft;

var myAudioAmp = 1.0;
var freqSpecs = ['bass', 'lowMid', 'mid', 'highMid'];
var freqEnergies = [];
var freqReductions = [0.5, 0.5, 0.6, 0.7];
var threshold = 100;
var yOffset = 25;


//GUI
var gui;
var myGUI;

//Star
var osc;
var starScale = 1;
var radius1;


//Smoothing variables
var xstarDepth = 0; 
var xradius1 = 0;
var globalEasing = 0.2; //The higher the number, the faster the movement (less easing)

function preload() {
  soundFile = loadSound('Broke_For_Free_-_01_-_As_Colorful_As_Ever.mp3');
}

function setup() {
  var cnv = createCanvas(windowWidth, windowHeight);
  //createCanvas(windowWidth, windowHeight);
  noStroke();

  // make canvas drag'n'dropablle with gotFile as the callback
  makeDragAndDrop(cnv, gotFile);

  //Sound
  mic = new p5.AudioIn();
  var smoothing = 0.001;
  fft = new p5.FFT(smoothing);

  toggleInput(1);

  //GUI
  myGUI = new GUILayout();
  gui = new dat.GUI();

  gui.add(myGUI, 'radius1', 0, height / 2).listen();
  gui.add(myGUI, 'centerFreeSpace', 0.3, 1.00);
  gui.add(myGUI, 'starDecrease', 0.01, 0.5);
  gui.add(myGUI, 'starDepth', 0.01, 0.9).listen();
  gui.add(myGUI, 'starEdges', 2, 16).step(1);
  gui.add(myGUI, 'rotationAmplitude', 0, 10);
  gui.add(myGUI, 'rotationPeriod', 500, 10000);

  //gui.close();
}

function draw() {
  background(0);

  //Sound
  var spectrum = fft.analyze();

  labelStuff();

  for (var i = 0; i < freqSpecs.length; i++) {
    freqEnergies[i] = fft.getEnergy(freqSpecs[i]) * freqReductions[i] * myAudioAmp;
    freqEnergies[i] = constrain(freqEnergies[i], 0, 100);

    if (freqEnergies[i] == 100) {
      fill(0, 255, 0);
    } else {
      fill(255);
    }
    stroke(0);
    rect(i * 100, yOffset, 100, freqEnergies[i]);

    //fill(0);
    text(round(freqEnergies[i]), 40 + i * 100, yOffset - 10);
  }

  fill(255, 0, 0);
  line(0, height / 2 + threshold, 400, yOffset + threshold);

  
  //Use FFT values for animation
  //myGUI.radius1= freqEnergies[0]*6;
  
  var targetRadius1 = freqEnergies[0]*6;
  var dxradius1 = targetRadius1 - xradius1;
  xradius1+=dxradius1*globalEasing;
  myGUI.radius1= xradius1;
  
  
  // Easing starDepth (controlled by snare)
  var targetstarDepth = freqEnergies[3]/100.0;
  var dxstarDepth = targetstarDepth - xstarDepth;
  xstarDepth+=dxstarDepth*globalEasing;
  //console.log(dxstarDepth);
  //cp5.getController("starDepth").setValue(xstarDepth);
  
  myGUI.starDepth = xstarDepth;
  
  //Star
  osc = myGUI.rotationAmplitude * sin(TWO_PI * millis() / myGUI.rotationPeriod);

  push();
  translate(width / 2, height / 2);
  var internalStars = int(((myGUI.radius1 * 2 - myGUI.radius1 * 2.0 * myGUI.centerFreeSpace) + 1) / (myGUI.starDecrease * myGUI.radius1 * 2.0)) + 1;
  star(0, 0, myGUI.radius1, 1 - myGUI.starDepth, myGUI.starEdges, internalStars, myGUI.starDecrease);
  pop();

  starScale = 1;
}


function star(x, y, radius1, starDepth, starEdges, internalStars, starDecrease) {
  var angle = TWO_PI / starEdges;
  var halfAngle = angle / 2.0;

  for (var i = 0; i < internalStars; i++) {
    if (i % 2 == 0) {
      fill(255);
    } else {
      fill(0)
    }

    beginShape();
    for (var a = 0; a < TWO_PI; a += angle) {
      var sx = x + cos(a) * (1 - starDepth) * radius1;
      var sy = y + sin(a) * (1 - starDepth) * radius1;
      vertex(sx, sy);
      sx = x + cos(a + halfAngle) * radius1;
      sy = y + sin(a + halfAngle) * radius1;
      vertex(sx, sy);
    }
    rotate(radians(osc));
    starScale -= starDecrease;
    scale(starScale);
    endShape(CLOSE);
  }
}


var GUILayout = function() {
  this.radius1 = min(height / 2, width / 2 - 100);
  this.starDepth = 0.1;
  this.starEdges = 5;
  this.starDecrease = 0.01;
  this.centerFreeSpace = 0.30;
  this.rotationAmplitude = 5;
  this.rotationPeriod = 5000;
};



function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  myGUI.radius1 = min(height / 2, width / 2 - 100);;
}


// draw text
function labelStuff() {
  fill(255);
  textSize(18);

  push();
  translate(0, 120);
  if (soundFile.isPlaying()) {
    text('Current Time: ' + soundFile.currentTime().toFixed(3), 20, 20);
  }

  text('Current Source: ' + currentSource, 20, 40);
  textSize(14);
  text('Press T to toggle source', 20, 60);
  text('Drag a soundfile here to play it', 20, 100);
  pop();
}





// ==================
// Handle Drag & Drop
// ==================

function makeDragAndDrop(canvas, callback) {
  var domEl = getElement(canvas.elt.id);
  domEl.drop(callback);
}

function gotFile(file) {
  soundFile.dispose();
  soundFile = loadSound(file, function() {
    toggleInput(0);
  });
}


// ============
// toggle input
// ============

// in p5, keyPressed is not case sensitive, but keyTyped is
function keyPressed() {
  if (key == 'T') {
    toggleInput();
  }
}

// start with mic as input
var inputMode = 1;

function toggleInput(mode) {
  if (typeof(mode) === 'number') {
    inputMode = mode;
  } else {
    inputMode += 1;
    inputMode = inputMode % 2;
  }
  switch (inputMode) {
    case 0: // soundFile mode
      soundFile.play();
      mic.stop();
      fft.setInput(soundFile);
      currentSource = 'soundFile';
      break;
    case 1: // mic mode
      mic.start();
      soundFile.pause();
      fft.setInput(mic);
      currentSource = 'mic';
      break;
  }
}