//To do: 
// Do FFT analysis and let bass and snare (+ bpm?) drive some controls.

var gui;
var myGUI;

var osc;
var starScale = 1;
var radius1;


function setup() {

  createCanvas(windowWidth, windowHeight);
  noStroke();

  myGUI = new GUILayout();
  gui = new dat.GUI();
  
  gui.add(myGUI, 'radius1', 0, height/2).listen();
  gui.add(myGUI, 'centerFreeSpace', 0.3, 1.00);
  gui.add(myGUI, 'starDecrease', 0.01, 0.5);
  gui.add(myGUI, 'starDepth', 0.01, 0.9);
  gui.add(myGUI, 'starEdges', 2, 16).step(1);
  gui.add(myGUI, 'rotationAmplitude', 0, 10);
  gui.add(myGUI, 'rotationPeriod', 500, 10000);
  
  //gui.close();
}

function draw() {
  background(0);
  osc = myGUI.rotationAmplitude * sin(TWO_PI * millis() / myGUI.rotationPeriod);

  push();
  translate(width / 2, height / 2);
  var internalStars = int(((myGUI.radius1 * 2 - myGUI.radius1 * 2.0 * myGUI.centerFreeSpace) + 1) / (myGUI.starDecrease * myGUI.radius1 * 2.0)) + 1;
  star(0, 0, myGUI.radius1, myGUI.starDepth, myGUI.starEdges, internalStars, myGUI.starDecrease);
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