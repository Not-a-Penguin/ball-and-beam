//Nova interface pro ball & beam porque slider são uma porra

import controlP5.*;
import processing.serial.*;

Serial port;
ControlP5 cp5;
PImage img;
PImage back;

String kPValue = "", kPValue_aux;
String kIValue = "", kIValue_aux;
String kDValue = "", kDValue_aux;

boolean kptoggle;
boolean kitoggle;
boolean kdtoggle;

Slider setpoint;

void setup() {
  size(700, 400);
  PFont font = createFont("arial", 20);
  cp5 = new ControlP5(this);

  //port = new Serial(this, "COM3", 9600);

  img = loadImage("logo2.png");
  back = loadImage("ui_background.jpg");
  back.resize(700, 400);

  cp5.addTextfield("kP").setPosition(20, 100)
    .setSize(150, 40)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255));
  cp5.addTextfield("kI").setPosition(20, 200)
    .setSize(150, 40)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255));
  cp5.addTextfield("kD").setPosition(20, 300)
    .setSize(150, 40)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255));
  setpoint = cp5.addSlider("setpoint")
    .setPosition(385, 300)
    .setSize(250, 30)
    .setRange(0, 40)
    .setNumberOfTickMarks(40)
    .setLabelVisible(false);
  cp5.addToggle("kptoggle").setPosition(200, 105)
    .setSize(50, 25)
    .setCaptionLabel("On/Off")
    .setMode(ControlP5.SWITCH);
  cp5.addToggle("kitoggle").setPosition(200, 205)
    .setSize(50, 25)
    .setCaptionLabel("On/Off")
    .setMode(ControlP5.SWITCH);
  cp5.addToggle("kdtoggle").setPosition(200, 305)
    .setSize(50, 25)
    .setCaptionLabel("On/Off")
    .setMode(ControlP5.SWITCH);
  textFont(font);
}

void draw() {

  background(back);
  image(img, 475, 0, width/2.5, height/2.5);
  text("Sistema Ball & Beam", 250, 30);
  text("SetPoint =", 400, 290);
  text(int(setpoint.getValue()) + "cm", 495, 290);
  text("= ", 50, 165); text(kPValue, 65, 165);
  text("= ", 40, 263); text(kIValue, 55, 263);
  text("= ", 50, 363); text(kDValue, 65, 363);
}

public void kP(String kPValue_a) {
  kPValue = kPValue_a;
  if (kPValue_a.isEmpty() == false) {
    kPValue_aux = kPValue;
  }
  if (kptoggle == false) {
    kPValue = "0";
  } else kPValue = kPValue_aux;

  String mail = ">kP," + "1," + kPValue + "<";
  port.write(mail);
  println(mail);
}

public void kI(String kIValue_a) {
  kIValue = kIValue_a;
  if (kIValue_a.isEmpty()== false) {
    kIValue_aux = kIValue;
  }
  if (kitoggle == false) {
    kIValue = "0";
  } else kIValue = kIValue_aux;

  String mail = ">kI," + "2," + kIValue + "<";
  port.write(mail);
  println(mail);
}

public void kD(String kDValue_a) {
  kDValue = kDValue_a;
  if (kDValue_a.isEmpty() == false) {
    kDValue_aux = kDValue;
  }
  if (kdtoggle == false) {
    kDValue = "0";
  } else kDValue = kDValue_aux;

  String mail = ">kD," + "3," + kDValue + "<";
  port.write(mail);
  println(mail);
}

void setpoint() {
  float slide = setpoint.getValue();
  int slide2 = int(slide);
  String mail = ">setpoint, " + slide2 + ", 3.14<";
  println(mail);
  port.write(mail);
}
