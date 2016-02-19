import controlP5.*;
ControlP5 cp5;

float theta = 0.0;
float osc;

float starScale = 1;

int starOffest = 40;

int radius1 = 450;
float starDepth = 0.1;
float centerFreeSpace = 0;
int starEdges = 5;
float starDecrease = 0.01;
float rotationAmplitude = 5;
int rotationPeriod = 5000;


void setup() {
  //size(1200, 900);
  fullScreen();
  noStroke();

  cp5 = new ControlP5(this);
  cp5.addSlider("radius1", 0, height/2).linebreak();
  cp5.addSlider("centerFreeSpace", 0.0, 1.0).linebreak();
  //cp5.addSlider("starOfset",10,400).linebreak();
  cp5.addSlider("starDecrease", 0.01, 0.50).linebreak();
  cp5.addSlider("starDepth", 0.01, 0.90).linebreak();
  cp5.addSlider("starEdges", 2, 16).linebreak();
  cp5.addSlider("rotationAmplitude", 0, 10).linebreak();
  cp5.addSlider("rotationPeriod", 500, 10000).linebreak();
}

void draw() {
  background(#202020);

  osc = rotationAmplitude*sin(TWO_PI *millis()/rotationPeriod);   

  pushMatrix();
  translate(width/2, height/2);

  int internalStars = int(((radius1*2-radius1*2*centerFreeSpace)+1)/(starDecrease*radius1*2))+1;

  star(0, 0, radius1, starDepth, starEdges, internalStars, starDecrease); 
  popMatrix();

  starScale = 1;
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
    }

    rotate(radians(osc));

    starScale -= starDecrease;
    scale(starScale);

    endShape(CLOSE);
  }
}