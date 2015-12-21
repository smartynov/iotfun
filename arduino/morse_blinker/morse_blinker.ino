#define PIN_LED 1
#define PIN_SPEAKER 1

#include <morse.h>

//LEDMorseSender sender(PIN_LED);
SpeakerMorseSender speaker(
  PIN_SPEAKER,
  880,  // tone frequency
  -1,  // carrier frequency
  14);  // wpm

void setup() {
/*
  sender.setup();
//  sender.setMessage(String(F("lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")));
  sender.setMessage(msg);
//  sender.setMessage(String("lorem ipsum dolor sit amet "));
//  sender.setMessage(String("i love you "));
  sender.startSending();
*/
  speaker.setup();
  speaker.setMessage(String("lorem ipsum dolor sit amet, consectetur adipiscing elit"));
  speaker.startSending();
}

void loop() {
/*  if (!sender.continueSending())
  {
    delay(1000);
    sender.startSending();
  }
  */
  if (!speaker.continueSending())
  {
    delay(4000);
    speaker.startSending();
  }
}

