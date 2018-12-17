//
// a template for receiving face tracking osc messages from
// Kyle McDonald's FaceOSC https://github.com/kylemcdonald/ofxFaceTracker
//
// 2012 Dan Wilcox danomatika.com
// for the IACD Spring 2012 class at the CMU School of Art
//
// adapted from from Greg Borenstein's 2011 example
// http://www.gregborenstein.com/
// https://gist.github.com/1603230
//
import oscP5.*;
OscP5 oscP5;
 
 
//I used Dan Shiffman's box2d adaptation: https://github.com/shiffman/Box2D-for-Processing
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
 
Box2DProcessing box2d;
 
ArrayList<Boundary> boundaries;
ArrayList<ParticleSystem> systems;
ArrayList<Box> boxes;
 
// num faces found
int found;
 
// pose
float poseScale;
PVector posePosition = new PVector();
PVector poseOrientation = new PVector();
 
// gesture
float mouthHeight;
float mouthWidth;
float eyeLeft;
float eyeRight;
float eyebrowLeft;
float eyebrowRight;
float jaw;
float nostrils;
 
PImage outerEye;
 
float aVelocity = .05;
boolean mouseVelocity = false;
float angle = 0;
float amplitudeX = 200;
float amplitudeY = 200;
float theta = 0;
PVector location;
float centerX;
float centerY;
 
void setup() {
  size(640, 480);
  frameRate(30);
  smooth();
 
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
 
  box2d.setGravity(0, -20);
 
  systems = new ArrayList<ParticleSystem>();
  boundaries = new ArrayList<Boundary>();
  boxes = new ArrayList<Box>();
 
  oscP5 = new OscP5(this, 8338);
  oscP5.plug(this, "found", "/found");
  oscP5.plug(this, "poseScale", "/pose/scale");
  oscP5.plug(this, "posePosition", "/pose/position");
  oscP5.plug(this, "poseOrientation", "/pose/orientation");
  oscP5.plug(this, "mouthWidthReceived", "/gesture/mouth/width");
  oscP5.plug(this, "mouthHeightReceived", "/gesture/mouth/height");
  oscP5.plug(this, "eyeLeftReceived", "/gesture/eye/left");
  oscP5.plug(this, "eyeRightReceived", "/gesture/eye/right");
  oscP5.plug(this, "eyebrowLeftReceived", "/gesture/eyebrow/left");
  oscP5.plug(this, "eyebrowRightReceived", "/gesture/eyebrow/right");
  oscP5.plug(this, "jawReceived", "/gesture/jaw");
  oscP5.plug(this, "nostrilsReceived", "/gesture/nostrils");
 
 
  outerEye = loadImage("circlebig.png");
 
  //boundaries.add(new Boundary(0,490,1280,10,0));
 
}
 
void draw() {  
  semiTransparent();
 
  box2d.step();
 
  for (ParticleSystem system: systems) {
    system.run();
 
    int n = (int) random(0, 2);
    system.addParticles(n);
  }
 
  for (Boundary wall: boundaries) {
    wall.display();
  }
 
  float varVelocity = calcVelocity(aVelocity);
  PVector angularVelocity = new PVector (angle, varVelocity);
  PVector amplitude = new PVector (amplitudeX, amplitudeY);
  PVector location = calculateCircle(angularVelocity, amplitude);
  //PVector centerCircle = calculateCenter(centerX, centerY);
 
  pushMatrix();
  if(found > 0) {
    drawOscillatingX(location);
  }
  popMatrix();
 
  for (Box b: boxes) {
    b.display();
  }
}
 
void semiTransparent() {
  rectMode(CORNER);
  noStroke();
  float backColor = map (mouthHeight, 1, 5, 255, 0);
  fill(backColor, backColor, backColor, 40);
  rect(0,0, width, height);
  stroke(0);
  noFill();
}
 
//basics of eye blink, iris movement from: https://raw.githubusercontent.com/jayjaycody/ComputationalCameras/master/wk3_Face/jai_face_keyPressComplexity/jai_face_keyPressComplexity.pde
 
float calcVelocity(float aVelocity) {
  float velocity = aVelocity;
  if (mouseVelocity == false) {
  }
  if (mouseVelocity == true) {
    velocity = map(mouseX, 0, width, -1, 1);
  }
  return velocity;
}
 
PVector calculateCircle (PVector angularVelocity, PVector amplitude) {
  float x = amplitude.x * cos (theta);
  float y = amplitude.y * sin (theta);
  location = new PVector (x, y);
  theta += angularVelocity.y;
  return location;
}
 
PVector calculateCenter (float centerX, float centerY) {
  PVector centerCircle = new PVector (centerX, centerY);
  return centerCircle;
}
 
void drawOscillatingX (PVector location) {
 
    float mouthScalar = map(mouthWidth, 10, 18, 0, 1.5); // make a scalar for location.x as a function of mouth
    location.mult(mouthScalar);
 
    float newPosX = map (posePosition.x, 0, 640, 0, width);
    float newPosY = map(posePosition.y, 0, 480, 0, height);  
    translate(width - newPosX, newPosY-100);
    scale(poseScale*.3);
    float irisColR = map (mouthHeight, 1, 5, 102, 204);
    float irisColG = map (mouthHeight, 1, 5, 204, 51);
    float irisColB = map (mouthHeight, 1, 5, 255, 0);
 
    float leftEyeMove = map(location.x, - amplitudeX, amplitudeX, -25, 33);
    pushMatrix();
    translate (leftEyeMove, 0);
    //Left iris
    fill(irisColR, irisColG, irisColB);
    noStroke();
 
    float eyeMult = map (mouthHeight, 1, 5, 1, 2);
 
    float irisSizeL = map (eyeLeft, 2, 3.5, 0, 50);
    ellipse(-100, 0, irisSizeL * eyeMult, irisSizeL * eyeMult);
 
    ////LeftPupil
    float eyeOutlineCol = map (mouthHeight, 1, 5, 0, 255);
 
    popMatrix();
 
    float rightEyeMove = map(location.x, - amplitudeX, amplitudeX, -33, 25);
    pushMatrix();   
    translate(rightEyeMove, 0);
    //right EYE
    //Right Iris
    fill(irisColR, irisColG, irisColB);
    noStroke();
 
    float irisSizeR = map (eyeRight, 2, 3.5, 0, 50);
    ellipse(100, 0, irisSizeR * eyeMult, irisSizeR * eyeMult);
 
    //Right Pupil
    stroke(eyeOutlineCol); 
    popMatrix();
    noFill();
 
 
    //get eye informatio and set scalar
    float blinkAmountRight = map (eyeRight, 2.5, 3.8, 0, 125);
    float blinkAmountLeft = map (eyeLeft, 2.5, 3.8, 0, 125);
 
 
    float eyeMultiplier = map (mouthHeight, 1, 5, 1, 3);
    // right eye size, blink and movement
    ellipse (100, 0, amplitudeX *.6, blinkAmountRight * eyeMultiplier); //scalar added to eyeHeight
    if (eyeRight < 2.7) {
      fill(255, 230, 204);
      ellipse (100, 0, amplitudeX *.6, blinkAmountRight*1.6 * (4 * eyeMultiplier/5)); //scalar added to eyeHeight
      noFill();
    }
 
    //left eye size, blink, and movement
    ellipse (-100, 0, amplitudeX *.6, blinkAmountLeft * eyeMultiplier); 
    if (eyeLeft < 2.7) {
      fill(255, 230, 204);
      ellipse (-100, 0, amplitudeX *.6, blinkAmountLeft*1.6 * (4 * eyeMultiplier/5)); //scalar added to eyeHeight
      noFill();
    }
 
    if (mouthHeight > 3.3) {
      //float mapScale = map (poseScale, 0, 4, 0, 1);
      pushMatrix();
      //translate(posePosition.x, posePosition.y);
      //scale(poseScale);
      Box p = new Box((width - posePosition.x - 100), (posePosition.y - 50));
      Box q = new Box((width - posePosition.x + 100), (posePosition.y - 50));
      boxes.add(p);
      boxes.add(q);
      popMatrix();
    }
 
}
 
public void found(int i) {
  println("found: " + i);
  found = i;
}
 
public void poseScale(float s) {
  println("scale: " + s);
  poseScale = s;
}
 
public void posePosition(float x, float y) {
  println("pose position\tX: " + x + " Y: " + y );
  posePosition.set(x, y, 0);
}
 
public void poseOrientation(float x, float y, float z) {
  println("pose orientation\tX: " + x + " Y: " + y + " Z: " + z);
  poseOrientation.set(x, y, z);
}
 
public void mouthWidthReceived(float w) {
  println("mouth Width: " + w);
  mouthWidth = w;
}
 
public void mouthHeightReceived(float h) {
  println("mouth height: " + h);
  mouthHeight = h;
}
 
public void eyeLeftReceived(float f) {
  println("eye left: " + f);
  eyeLeft = f;
}
 
public void eyeRightReceived(float f) {
  println("eye right: " + f);
  eyeRight = f;
}
 
public void eyebrowLeftReceived(float f) {
  println("eyebrow left: " + f);
  eyebrowLeft = f;
}
 
public void eyebrowRightReceived(float f) {
  println("eyebrow right: " + f);
  eyebrowRight = f;
}
 
public void jawReceived(float f) {
  println("jaw: " + f);
  jaw = f;
}
 
public void nostrilsReceived(float f) {
  println("nostrils: " + f);
  nostrils = f;
}
 
// all other OSC messages end up here
void oscEvent(OscMessage m) {
  if(m.isPlugged() == false) {
    println("UNPLUGGED: " + m);
  }
}
