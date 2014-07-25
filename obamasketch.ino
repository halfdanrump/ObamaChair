/*

Copyright (c) 2012, 2013 RedBearLab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

//"services.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <boards.h>
#include <RBL_nRF8001.h>
#include <services.h>

 
#define ANALOG_IN_PIN      A3
#define ANALOG_BACK        A0
#define ANALOG_LEFT        A1
#define ANALOG_RIGHT     A2

float const byte_scaling = 0.249266;

void setup()
{
  // Default pins set to 9 and 8 for REQN and RDYN
  // Set your REQN and RDYN here before ble_begin() if you need
  //ble_set_pins(3, 2);
  
  // Set your BLE Shield name here, max. length 10
  //ble_set_name("My Name");
  
  // Init. and start BLE library.
  ble_begin();
  
  // Enable serial debug
  Serial.begin(57600);
  
}

void loop()
{
  
  // If data is ready
  while(ble_available())  {
    // read out commnd and data
    byte data0 = ble_read();
    byte data1 = ble_read();
    byte data2 = ble_read();
  }    
    
    // Read and send out
  uint16_t value = analogRead(ANALOG_IN_PIN) * byte_scaling; 
  uint16_t reading_left = analogRead(ANALOG_LEFT) * byte_scaling; 
  uint16_t reading_right = analogRead(ANALOG_RIGHT) * byte_scaling; 
  uint16_t reading_back = analogRead(ANALOG_BACK) * byte_scaling; 

  ble_write(0x0B);
  ble_write(reading_left);
  ble_write(reading_right);
  ble_write(reading_back);
 
  if (!ble_connected()) {

  }
  
  // Allow BLE Shield to send/receive data
  ble_do_events();  
}



