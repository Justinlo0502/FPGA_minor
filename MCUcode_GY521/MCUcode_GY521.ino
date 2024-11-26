#include <Wire.h>

const int MPU = 0x68; 
int16_t AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;

void setup() {
  Serial.begin(9600);
  Wire.begin();
  Wire.beginTransmission(MPU);
  Wire.write(0x6B);
  Wire.write(0);
  Wire.endTransmission(true);
  delay(1000);
}

void loop() {
  Wire.beginTransmission(MPU);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 14, true);

  AcX = Wire.read() << 8 | Wire.read();    
  AcY = Wire.read() << 8 | Wire.read();  
  AcZ = Wire.read() << 8 | Wire.read();  
  Tmp = Wire.read() << 8 | Wire.read();
  GyX = Wire.read() << 8 | Wire.read();  
  GyY = Wire.read() << 8 | Wire.read();  
  GyZ = Wire.read() << 8 | Wire.read();  

  // Map AcY from -32767 to +32767 to range 0-100
  int scaledAcY = map(AcY, -32767, 32767, 0, 200);
  scaledAcY = constrain(scaledAcY, 0, 200);

  Serial.write(scaledAcY);
  // adjust the delay based on how fast we need to data
  delay(10);
}