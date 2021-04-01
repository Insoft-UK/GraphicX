/*
Copyright © 2021 Insoft. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include "UniversalPictureFormat.h"

static void palette(const void *st_pal, uint32_t *pal);

UniversalPictureFormat getUniversalPictureFormat(const void *rawData, long unsigned int length) {
    UniversalPictureFormat upf = {
        .planeCount = 4,
        .bitsPerPixel = 16,
        .width = 320,
        .height = 200,
        .imageDataOffset = 0,
        .paletteAnim = false
    }; // Pre-Defined Values
    
    if (isNEOchromeFormat(rawData, length) == true) {
        NEOchrome *neo = (NEOchrome *)rawData;
        upf.imageDataOffset = sizeof(NEOchrome);
        palette(&neo->palette, upf.palette);
        
        if (swapInt16BigToHost(neo->colorAniLimits) & 1<<15) { // Animated Palette ON!
            upf.numOfColors = 16;
            upf.paletteAnim = true;
            upf.colorLowerLimit = (swapInt16BigToHost(neo->colorAniLimits) >> 4) & 15;
            upf.colorUpperLimit = swapInt16BigToHost(neo->colorAniLimits) & 15;
            upf.animSpeed = swapInt16BigToHost(neo->colorAniSpeedDir) & 255;
            if (swapInt16BigToHost(neo->colorAniSpeedDir) & 0x80) {
                upf.animSpeed = -upf.animSpeed;
            }
            upf.numOfColorSteps = swapInt16BigToHost(neo->numOfColorSteps) & 15;
            if (swapInt16BigToHost(neo->numOfColorSteps) & 16) {
                upf.numOfColorSteps = -upf.numOfColorSteps;
            }
        }
        
        
        upf.lengthInBytes = 32000 + upf.imageDataOffset;
        return upf;
    }
    
    return upf;
}

static void palette(const void *st_pal, uint32_t *pal) {
    uint8_t *bytes = (uint8_t *)st_pal;
    
    for (int i=0; i<16; i++) {
        /* Atari ST palettes
         * xx xx xx xx xx R2 R1 R0  xx G2 G1 G0 xx B2 B1 B0
         *
         * Atari STE palettes
         * xx xx xx xx R0 R3 R2 R1  G0 G3 G2 G1 B0 B3 B2 B1
         *
         */
        
        uint32_t r;
        r = (uint32_t)(((bytes[i * 2] << 1) & 0x0f) | (bytes[0] >> 3));
        r |= r << 4;
        
        uint32_t g;
        g = (uint32_t)(((bytes[i * 2 + 1] << 1) & 0xf0) | ((bytes[i * 2 + 1] & 0xf0) >> 3));
        g |= g >> 4;
        
        uint32_t b;
        b = (uint32_t)(((bytes[i * 2 + 1] << 1) & 0x0f) | ((bytes[i * 2 + 1] & 0x0f) >> 3));
        b |= b << 4;
    
    
        pal[i] = 0xff000000 | r | g << 8 | b << 16;
    }
}
