#include <Adafruit_NeoPixel.h>

//#define DEBUG

#define PIN         0
#define NUMPIXELS   60

#define NWAVES 1

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
/*
typedef struct {
  float len;
  float pos;
  float amp;
  float spd;
} wave;

wave waves[1];
*/

float spdr = 0.31;
float spdg = 0.27;
float spdb = 0.19;

float spd = 1.0;
float offset = 0.0;

void setup() {
  randomSeed(analogRead(0));
  strip.begin();
  strip.show();
  spdr = 2.0+sin(random(10000)/100.0);
  spdg = 2.0+sin(random(10000)/100.0);
  spdb = 2.0+sin(random(10000)/100.0);
  offset = 100*sin(random(10000)/100.0);
/*  waves[0].len = 1;
  waves[0].pos = 1;
  waves[0].amp = 1;
  waves[0].spd = 1;*/
}

#ifdef DEBUG
long nextms = 0;
int pfps = 0, fps = 0;
#endif

float myexp(float x) {
  return (1.0/(1.0-(0.634-1.344*x)*x));
}

void loop() {
  long ms = millis();

  float m = offset + ms/34500.0;
  spd = 5.7 + 1.5*sin(m/25.0) + 2.5*sin(1+m/97.0);
  float posr = 0.5 + 0.55*sin(spd*m*spdr);
  float posg = 0.5 + 0.55*sin(spd*m*spdg);
  float posb = 0.5 + 0.55*sin(spd*m*spdb);
  for (int i=0; i<NUMPIXELS; i++) {
    float ppos = (float)i / NUMPIXELS;
    float dr = ppos-posr;
    float dg = ppos-posg;
    float db = ppos-posb;
    strip.setPixelColor(i,
      constrain(255*myexp(-90*dr*dr),0,255),
      constrain(255*myexp(-70*dg*dg),0,255),
      constrain(255*myexp(-50*db*db),0,255)
      );
  }

#ifdef DEBUG
  // keep track of fps
  fps++;
  if (ms>nextms) {
    nextms = ms + 1000;
    pfps = fps;
    fps = 0;
  }
  strip.setPixelColor(pfps,255,255,255);
#endif

  strip.show();
}


