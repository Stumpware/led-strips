/*
Arduino library to simulate particle emission with an RGB LED strip.
Copyright (C) Stumpware
MIT license
*/

#include "ParticleEmitter.h"
#define MAX_COLOR 127

/*****************************************************************************/

ParticleEmitter::ParticleEmitter(uint16_t n) {
    numPixels = n;
    numParticles = MAX_PARTICLES;
    maxVelocity = float(numParticles / 2000.0);
    stripPosition = random(100) / 100.0;  // 0.0 - 1.0
    
    for (int i=0; i < MAX_PARTICLES; i++) {
        particles[i] = newParticle();
    }
}

particle ParticleEmitter::newParticle() {
    particle p;
    
    int8_t direction = (random(2) == 0 ? 1 : -1);

//    uint8_t maxColor = (random(2) == 0 ? MAX_COLOR/(random(35)+5) : 0);
    uint8_t maxColor = MAX_COLOR/(random(20)+5);

    p.velocity = ((random(99) + 1) / 100.0) * direction;
    
    if (direction > 0) {
        p.redColor = random(maxColor);
        p.greenColor = random(maxColor*0.25);
        p.blueColor = random(maxColor*0.75);
    }
    else {
        p.redColor = random(maxColor);
        p.greenColor = random(maxColor*0.25);
        p.blueColor = random(maxColor*0.75);
    }
    
    p.startTime = millis();
    p.startStripPosition = stripPosition;
    p.currentStripPosition = p.startStripPosition;
    
    return p;
}

void ParticleEmitter::begin(void) {
}

particle ParticleEmitter::updateParticle(uint16_t i) {
    particle *p = &particles[i];
    
    p->currentStripPosition = p->currentStripPosition +
                              (maxVelocity * p->velocity);  // *
                              //float(millis() - p->startTime);

    if (0) {
        if (p->currentStripPosition < 0.0)
            p->currentStripPosition = 1.0;
        else if (p->currentStripPosition > 1.0)
            p->currentStripPosition = 0.0;
    }
    else {
        if (p->currentStripPosition < -1.0 || p->currentStripPosition > 2.0)
            *p = newParticle();
    }

    return *p;
}



