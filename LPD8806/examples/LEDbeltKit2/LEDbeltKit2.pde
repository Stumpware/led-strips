//
// This program is for the Adafruit LED Belt kit.
//    http://www.adafruit.com/products/332
//
// Here is the LED strip.  
//    http://www.adafruit.com/products/306
//
// The microcontroller is the Adafruit ATMega32u4 breakout board.
//    http://www.adafruit.com/products/296
//
// Install Teensyduino to upload programs onto your board.
//    http://learn.adafruit.com/digital-led-belt/upload-the-test-sketch
//
// NOTE:  The LED strip in the belt kit uses LPD8806 chips to control the LEDs.
// For other strips with other chips there are other libraries, for example 
// this WP2811 based strip instead which uses "Adafruit_NeoPixel.h" instead of "LPD8806.h". 
//    http://www.adafruit.com/products/1376
//


#include "LPD8806.h"
#include "SPI.h"



// Example to control LPD8806-based RGB LED Modules in a strip!
/*****************************************************************************/
#define MAX_COLOR 127
#define NUM_PIXELS 32


#if defined(USB_SERIAL) || defined(USB_SERIAL_ADAFRUIT)
// this is for teensyduino support
int dataPin = 2;
int clockPin = 1;
#else 
// these are the pins we use for the LED belt kit using
// the Leonardo pinouts

// PMA: I'm pretty sure this is what our Adafruit "atmega32u4 breakout"

// Here is our wonderful microcontroller:
// http://www.adafruit.com/products/296


int dataPin = 16;
int clockPin = 15;
#endif

// Set the first variable to the NUMBER of pixels. 32 = 32 pixels in a row
// The LED strips are 32 LEDs per meter but you can extend/cut the strip
LPD8806 strip = LPD8806(NUM_PIXELS, dataPin, clockPin);



void setup() {
  
//  Serial.begin(9600);
  
  // Start up the LED strip
  strip.begin();

  // Update the strip, to start they are all 'off'
  strip.show();
}

///
// function prototypes, keep here!
///
void clearStrip();
void strobeFadeOut(uint8_t red, uint8_t green, uint8_t blue, float brightnessScale, uint8_t strobesPerSec);

///
// Adafruit gave us these ones for starters:
///
void colorChase(uint32_t c, uint8_t wait);
void colorWipe(uint32_t c, uint8_t wait);
void dither(uint32_t c, uint8_t wait);
void scanner(uint8_t r, uint8_t g, uint8_t b, uint8_t wait);
void wave(uint32_t c, int cycles, uint8_t wait);
void rainbowCycle(uint8_t wait);
uint32_t Wheel(uint16_t WheelPos);

void loop() {

  strobeFadeOut(MAX_COLOR, MAX_COLOR, 0, 0.01, 1);
  
}

void strobeFadeOut(uint8_t red, 
                   uint8_t green,
                   uint8_t blue,
                   float brightnessScale,
                   uint8_t strobesPerSec) {
  // Fade out
  
  double colorScale = 1.0;
  double minColorScale = 0.0005;
  double decay = 0.1;
  int i;
  uint16_t fadeWaitTime = 5; //strobesPerSec * 1000 / 8;  // cheating on the math here...how do you count how many times you can divide a number by 2 before it goes less than zero?
//  uint16_t totalFadeTime = 0;

  while (colorScale > minColorScale) {
    colorScale = colorScale - (colorScale * decay);// float(currentBrightness / originalBrightness * 0.01);
    
    double s = colorScale * brightnessScale;
    int redScaled = (red * s);
    int greenScaled = (green * s);
    int blueScaled = (blue * s);
  Serial.print("s: ");
  Serial.println(colorScale);
//  Serial.print("red: ");
//  Serial.println(redScaled);


    for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, strip.Color(redScaled, greenScaled, blueScaled));
    }
    
    strip.show();
    delay(fadeWaitTime);    
    
    fadeWaitTime = fadeWaitTime - (fadeWaitTime * decay * 10);
  }

  Serial.println("clearing");
    for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, strip.Color(0, 0, 0));
    }
    
    strip.show();

//  clearStrip();
  delay(2000);
}

void loopEverything() {

  // Send a simple pixel chase in...
  colorChase(strip.Color(127,127,127), 20); // white
  colorChase(strip.Color(127,0,0), 20);     // red
  colorChase(strip.Color(127,127,0), 20);   // yellow
  colorChase(strip.Color(0,127,0), 20);     // green
  colorChase(strip.Color(0,127,127), 20);   // cyan
  colorChase(strip.Color(0,0,127), 20);     // blue
  colorChase(strip.Color(127,0,127), 20);   // magenta

  // Fill the entire strip with...
  colorWipe(strip.Color(127,0,0), 20);      // red
  colorWipe(strip.Color(0, 127,0), 20);     // green
  colorWipe(strip.Color(0,0,127), 20);      // blue
  colorWipe(strip.Color(0,0,0), 20);        // black

  // Color sparkles
  dither(strip.Color(0,127,127), 50);       // cyan, slow
  dither(strip.Color(0,0,0), 15);           // black, fast
  dither(strip.Color(127,0,127), 50);       // magenta, slow
  dither(strip.Color(0,0,0), 15);           // black, fast
  dither(strip.Color(127,127,0), 50);       // yellow, slow
  dither(strip.Color(0,0,0), 15);           // black, fast

  // Back-and-forth lights
  scanner(127,0,0, 30);        // red, slow
  scanner(0,0,127, 15);        // blue, fast

  // Wavy ripple effects
  wave(strip.Color(127,0,0), 4, 20);        // candy cane
  wave(strip.Color(0,0,100), 2, 40);        // icy

  // make a pretty rainbow cycle!
  rainbowCycle(0);  // make it go through the cycle fairly fast

  // Clear strip data before start of next effect
  for (int i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);
  }
}

// Cycle through the color wheel, equally spaced around the belt
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for (j=0; j < 384 * 5; j++) {     // 5 cycles of all 384 colors in the wheel
    for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color
      // wheel (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
      strip.setPixelColor(i, Wheel(((i * 384 / strip.numPixels()) + j) % 384));
    }
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// fill the dots one after the other with said color
// good for testing purposes
void colorWipe(uint32_t c, uint8_t wait) {
  int i;

  for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
      strip.show();
      delay(wait);
  }
}

// Chase a dot down the strip
// good for testing purposes
void colorChase(uint32_t c, uint8_t wait) {
  int i;

  for (i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);  // turn all pixels off
  }

  for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, c); // set one pixel
      strip.show();              // refresh strip display
      delay(wait);               // hold image for a moment
      strip.setPixelColor(i, 0); // erase pixel (but don't refresh yet)
  }
  strip.show(); // for last erased pixel
}

// An "ordered dither" fills every pixel in a sequence that looks
// sparkly and almost random, but actually follows a specific order.
void dither(uint32_t c, uint8_t wait) {

  // Determine highest bit needed to represent pixel index
  int hiBit = 0;
  int n = strip.numPixels() - 1;
  for(int bit=1; bit < 0x8000; bit <<= 1) {
    if(n & bit) hiBit = bit;
  }

  int bit, reverse;
  for(int i=0; i<(hiBit << 1); i++) {
    // Reverse the bits in i to create ordered dither:
    reverse = 0;
    for(bit=1; bit <= hiBit; bit <<= 1) {
      reverse <<= 1;
      if(i & bit) reverse |= 1;
    }
    strip.setPixelColor(reverse, c);
    strip.show();
    delay(wait);
  }
  delay(250); // Hold image for 1/4 sec
}

// "Larson scanner" = Cylon/KITT bouncing light effect
void scanner(uint8_t r, uint8_t g, uint8_t b, uint8_t wait) {
  int i, j, pos, dir;

  pos = 0;
  dir = 1;

  for(i=0; i<((strip.numPixels()-1) * 8); i++) {
    // Draw 5 pixels centered on pos.  setPixelColor() will clip
    // any pixels off the ends of the strip, no worries there.
    // we'll make the colors dimmer at the edges for a nice pulse
    // look
    strip.setPixelColor(pos - 2, strip.Color(r/4, g/4, b/4));
    strip.setPixelColor(pos - 1, strip.Color(r/2, g/2, b/2));
    strip.setPixelColor(pos, strip.Color(r, g, b));
    strip.setPixelColor(pos + 1, strip.Color(r/2, g/2, b/2));
    strip.setPixelColor(pos + 2, strip.Color(r/4, g/4, b/4));

    strip.show();
    delay(wait);
    // If we wanted to be sneaky we could erase just the tail end
    // pixel, but it's much easier just to erase the whole thing
    // and draw a new one next time.
    for(j=-2; j<= 2; j++) 
        strip.setPixelColor(pos+j, strip.Color(0,0,0));
    // Bounce off ends of strip
    pos += dir;
    if(pos < 0) {
      pos = 1;
      dir = -dir;
    } else if(pos >= strip.numPixels()) {
      pos = strip.numPixels() - 2;
      dir = -dir;
    }
  }
}

// Sine wave effect
#define PI 3.14159265
void wave(uint32_t c, int cycles, uint8_t wait) {
  float y;
  byte  r, g, b, r2, g2, b2;

  // Need to decompose color into its r, g, b elements
  g = (c >> 16) & 0x7f;
  r = (c >>  8) & 0x7f;
  b =  c        & 0x7f; 

  for(int x=0; x<(strip.numPixels()*5); x++)
  {
    for(int i=0; i<strip.numPixels(); i++) {
      y = sin(PI * (float)cycles * (float)(x + i) / (float)strip.numPixels());
      if(y >= 0.0) {
        // Peaks of sine wave are white
        y  = 1.0 - y; // Translate Y to 0.0 (top) to 1.0 (center)
        r2 = 127 - (byte)((float)(127 - r) * y);
        g2 = 127 - (byte)((float)(127 - g) * y);
        b2 = 127 - (byte)((float)(127 - b) * y);
      } else {
        // Troughs of sine wave are black
        y += 1.0; // Translate Y to 0.0 (bottom) to 1.0 (center)
        r2 = (byte)((float)r * y);
        g2 = (byte)((float)g * y);
        b2 = (byte)((float)b * y);
      }
      strip.setPixelColor(i, r2, g2, b2);
    }
    strip.show();
    delay(wait);
  }
}

/* Helper functions */

//Input a value 0 to 384 to get a color value.
//The colours are a transition r - g - b - back to r

uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch(WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128; // red down
      g = WheelPos % 128;       // green up
      b = 0;                    // blue off
      break;
    case 1:
      g = 127 - WheelPos % 128; // green down
      b = WheelPos % 128;       // blue up
      r = 0;                    // red off
      break;
    case 2:
      b = 127 - WheelPos % 128; // blue down
      r = WheelPos % 128;       // red up
      g = 0;                    // green off
      break;
  }
  return(strip.Color(r,g,b));
}


void clearStrip() {
  // Clear strip data before start of next effect
  for (int i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);
  }
  strip.show();
}


