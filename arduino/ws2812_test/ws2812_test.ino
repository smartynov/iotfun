#include <Adafruit_NeoPixel.h>

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

float posr = 0;
float posg = 0;
float posb = 0;

float spdr = 0.31;
float spdg = 0.27;
float spdb = 0.19;

float spd = 1.0;

void setup() {
  randomSeed(analogRead(0));
  strip.begin();
  strip.show();
  posr = sin(random(10000)/100.0);
  posg = sin(random(10000)/100.0);
  posb = sin(random(10000)/100.0);
  spdr = 1.0;//2.0+sin(random(10000)/100.0);
  spdg = 2.0+sin(random(10000)/100.0);
  spdb = 3.0;//2.0+sin(random(10000)/100.0);
/*  waves[0].len = 1;
  waves[0].pos = 1;
  waves[0].amp = 1;
  waves[0].spd = 1;*/
  myexp_setup();
}

//int j = 0;

/*
int dirr = 1;
int dirg = 1;
int dirb = 1;
*/

long nextms = 0;
int pfps = 0, fps = 0;

//#define sin(x) (0)
//#define exp(x) (1.0/(x+1.0))
//#define exp(x) (1.0/(1.0-3*x))
//#define exp(x) (1.0/((1.0-x)*(1.0-x)))
//#define exp(x) (1.0/(1.0-x+0.5*x*x))

//#define exp(x) (1.0/(1.0-(0.634-1.344*x)*x))
//#define exp(x) (myexp(x))

#define MYEXP_MIN -20.0
#define MYEXP_MAX 0.0
#define MYEXP_NUM 20
#define MYEXP_STEP (((float)MYEXP_MAX-(float)MYEXP_MIN)/(MYEXP_NUM-1))
float myexp_table[MYEXP_NUM];
void myexp_setup() {
  float x = MYEXP_MIN;
  for(int i=0; i<MYEXP_NUM; i++) {
 //   myexp_table[i] = (1.0/(1.0-(0.634-1.344*x)*x));
    myexp_table[i] = exp(x);
    x += MYEXP_STEP;
  }
}
float myexp(float x) {
  if (x<MYEXP_MIN) return 0; //myexp_table[0];
  if (x>MYEXP_MAX) return 1; //myexp_table[MYEXP_NUM-1];
  float xp = (x - (float)MYEXP_MIN)/MYEXP_STEP;
  int il = floor(xp);
  int ih = ceil(xp);
  float wl = xp/MYEXP_STEP - il;
  return myexp_table[il]*wl + myexp_table[ih]*(1.0-wl);
//  return (1.0/(1.0-(0.634-1.344*x)*x));
}
float myexp1(float x) {
  if (x<MYEXP_MIN) return 0; //myexp_table[0];
  if (x>MYEXP_MAX) return 1; //myexp_table[MYEXP_NUM-1];
  float xp = (x - (float)MYEXP_MIN)/MYEXP_STEP;
  int il = floor(xp);
  int ih = ceil(xp);
  float wl = xp - il;
  return myexp_table[il];
//  return (1.0/(1.0-(0.634-1.344*x)*x));
}

void loop() {
  long ms = millis();

  float m = ms/34500.0;
  spd = 5.7 + 1.5*sin(m/25.0) + 2.5*sin(1+m/97.0);
  posr = 0.5 + 0.55*sin(spd*m*spdr);
//  posg = 0.5 + 0.55*sin(spd*m*spdg);
  posb = 0.5 + 0.55*sin(spd*m*spdb);
  for (int i=0; i<NUMPIXELS; i++) {
    float ppos = (float)i / NUMPIXELS;
    float dr = ppos-posr;
 //   float dg = ppos-posg;
    float db = ppos-posb;
//    strip.setPixelColor(i,constrain(2*i,0,125),constrain(i+j,0,125),constrain(2*i-j,0,125));
    strip.setPixelColor(i,
      constrain(255*myexp1(-90*dr*dr),0,255),
      0,//constrain(255*exp(-70*dg*dg),0,255),
      constrain(255*myexp(-50*db*db),0,255)
      );
/*    strip.setPixelColor(i,
      i == j-2  ? strip.Color(60,10,10) :
      i == j-1  ? strip.Color(150,100,50) :
      i == j    ? strip.Color(150,255,150) :
      i == j+1  ? strip.Color(50,100,150) :
      i == j+2  ? strip.Color(10,10,60) :
      strip.Color(0,0,0)
    );*/
  }
/*  posr += spdr*dirr;
  posg += spdg*dirg;
  posb += spdb*dirb;
  if (posr >= 1.0) { dirr = -1; }
  if (posg >= 1.0) { dirg = -1; }
  if (posb >= 1.0) { dirb = -1; }
  if (posr < 0.0) { dirr = 1; }
  if (posg < 0.0) { dirg = 1; }
  if (posb < 0.0) { dirb = 1; }*/
/*
  if (j<NUMPIXELS) {
    j++;
//    delay(250);
  }
  else {
    j=0;
//    delay(250);
  }*/

  // keep track of fps
  fps++;
  if (ms>nextms) {
    nextms = ms + 1000;
    pfps = fps;
    fps = 0;
  }
  strip.setPixelColor(pfps,255,255,255);

  strip.show();
}


