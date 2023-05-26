#include <Servo.h>
#include <Ultrasonic.h>
#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <String.h>

//variáveis do servo, LCD e do sensor ==================

#define trigger 5
#define echo 4

Servo atuador;
Ultrasonic distance_sensor(trigger, echo);

LiquidCrystal_I2C lcd = LiquidCrystal_I2C(0x27, 16, 2);

//variáveis do PID ============================

float setPoint = 25;
double error = 0;
double lastDist = 0;
long lastProcess = 0;

double kP = 1.2,
       kI = 0.1,
       kD = 0.008;

double P = 0, I = 0, D = 0;

double PID = 0;
double dist = 0;
int angle = 95;

//variáveis de comunicação serial =================

const byte numChars = 32;
char receivedChars [numChars];
char tempChars[numChars];

//variáveis de parsing===========================

char messageFromPC[numChars] = {0};
int integerFromPC = 0;
float floatFromPC = 0.0;

boolean newData = false;

//======================

void setup() {
  Serial.begin(9600);
  atuador.attach(6);
  lcd.init();
  lcd.backlight();
}

void loop() {
//Comunicação ===================================

  recvWithStartEndMarkers();
  if(newData == true){
    strcpy(tempChars, receivedChars);
    ParseData();
    newData = false;
  }

  if(strcmp(messageFromPC, "kP") == 0){
    kP = floatFromPC;  
  }
  if(strcmp(messageFromPC, "kI") == 0){
    kI = floatFromPC;  
  }
  if(strcmp(messageFromPC, "kD") == 0){
    kD = floatFromPC;  
  }
  if(strcmp(messageFromPC, "setpoint") == 0){
    setPoint = integerFromPC;
  }

//PID =================================

  double dist = distance_sensor.read();
    if(dist > 36){
      dist = 36;
    }
  calculatePID();
  atuador.write(angle);

//LCD ==================================

lcd.print(kP);lcd.print(" ");
lcd.print(kD,3);lcd.print(" ");
lcd.setCursor(0,1);
lcd.print(kI,3);
lcd.home();

}

void calculatePID(){
  //Implementação do PID
  error = setPoint - dist;
      
  float delta = (millis() - lastProcess) / 1000.0;
  lastProcess = millis();
      
  //P
  P = error * kP;
    
  //I 
  I += (error * kI) * delta;
    if (I > 10){
      I = 10;
    }
    
  //D
  D = (lastDist - dist) * kD * delta;
  lastDist = dist;
    
  //criar o PID 
  PID = P + I + D;
      
  //Levar para saída compensando com o ângulo horizontal da barra
  angle = PID + 95;

}

void recvWithStartEndMarkers(){
  static boolean recvInProgress = false;
  static byte ndx = 0;
  char startMarker = '>';
  char endMarker = '<';
  char rc;

  while(Serial.available() > 0 && newData == false){
    rc = Serial.read();

    if(recvInProgress == true){
      if(rc != endMarker){
        receivedChars[ndx] = rc;
        ndx++;
        if(ndx >= numChars){
          ndx = numChars - 1;  
        }  
      }
      else{
        receivedChars[ndx] = '\0';
        recvInProgress = false;
        ndx = 0;
        newData = true;
      }
    }

    else if(rc == startMarker){
      recvInProgress = true;  
    }
  }
}

void ParseData(){
  
  char * strtokIndx;

  strtokIndx = strtok(tempChars,",");
  strcpy(messageFromPC, strtokIndx);

  strtokIndx = strtok(NULL,",");
  integerFromPC = atoi(strtokIndx);
 
  strtokIndx = strtok(NULL,",");
  char *eptr;
  floatFromPC = strtod(strtokIndx, &eptr);
}
