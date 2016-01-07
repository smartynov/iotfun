
#define PIN 13

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin 13 as an output.
  pinMode(PIN, OUTPUT);
  Serial.begin(9600);
}

float vsmooth = 0;

#define SMOOTH_FACTOR 0.9

// the loop function runs over and over again forever
void loop() {
  digitalWrite(PIN, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1000);              // wait for a second
  digitalWrite(PIN, LOW);    // turn the LED off by making the voltage LOW
  delay(100);              // wait for a second
  int sensorValue = analogRead(A0);
  float voltage = sensorValue * (5.0 / 1023.0);
  vsmooth = vsmooth * SMOOTH_FACTOR + voltage * (1.0 - SMOOTH_FACTOR);
  Serial.println(vsmooth);
}


