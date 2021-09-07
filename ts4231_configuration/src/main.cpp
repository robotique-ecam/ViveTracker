#include <Arduino.h>

/*
bool flag = true;
int cpt = 0;

void setup() {
  Serial.begin(115200);
  pinMode(12, OUTPUT);
  pinMode(13, OUTPUT);
}

void loop() {
  flag = !flag;
  Serial.println("i'm alive!!! " + (String)cpt);
  digitalWrite(12, flag);
  digitalWrite(13, flag);
  delay(100);
}
*/

#include <ts4231.h>

#define light_timeout   5000  //500ms is a placeholder as this number will be system dependent

//IMPORTANT NOTES:
//1)  If porting the TS4231 library code to a non-Arduino architecture,
//    be sure that the INPUT ports assigned to the E and D signals are configured as
//    floating inputs with NO pull-up or pull-down function.  Using a pull-up or
//    pull-down function on the inputs will cause the TS4231 to operate incorrectly.
//2)  If a microcontroller is being used that can change states on the E and D
//    outputs faster than approximately 100ns, see the IMPORTANT NOTES section
//    in file ts4231.cpp for more information.

#define device1_E_pin   12   // D6
#define device1_D_pin   13   // D7

uint8_t config_result;

TS4231  device1(device1_E_pin, device1_D_pin);  //instantiate the class as device1 and assign pins

void setup() {
  Serial.begin(115200);
  while (!Serial);  //wait for serial port to connect

  Serial.println("Serial Port Connected");
  Serial.println("waiting for 5 seconds");
  Serial.println();

//The application must verify that each TS4231 has detected light prior to
//configuring the device.  The waitForLight() function is executed after power-up
//on an un-configured device.  Once the device has detected light, waitForLight()
//does not need to be executed again unless the device loses power.
  if (device1.waitForLight(light_timeout)) {
    
    //Execute this code when light is detected
    Serial.println("Light DETECTED");
    
    config_result = device1.configDevice();
  
    //user can determine how to handle each return value for the configuration function
    switch (config_result) {
      case CONFIG_PASS:
        Serial.println("Configuration SUCCESS");
        break;
      case BUS_FAIL:  //unable to resolve state of TS4231 (3 samples of the bus signals resulted in 3 different states)
        Serial.println("Configuration Unsuccessful - BUS_FAIL");
        break;
      case VERIFY_FAIL:  //configuration read value did not match configuration write value, run configuration again
        Serial.println("Configuration Unsuccessful - VERIFY_FAIL");
        break;
      case WATCH_FAIL:  //verify succeeded but entry into WATCH mode failed, run configuration again
        Serial.println("Configuration Unsuccessful - WATCH_FAIL");
        break;
      default:  //value returned was unknown
        Serial.println("Program Execution ERROR");
        break;
      }
    }
  else {
    //insert code here for no light detection
    Serial.println("Light TIMEOUT");
    }
  Serial.println("");
  }
  
void loop() {
  //insert your main code here
  }
