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

#ifndef UniversalPictureFormat_h
#define UniversalPictureFormat_h

#include "NEOchrome.h"

typedef struct {
    const char title[128];
    int planeCount;                 // Number of bit planes
    int bitsPerPixel;               // 1 Monochrome (B/W) : 2,3,4...8,9,10 (Color)
    
    int width;
    int height;
    
    ulword palette[256];
    
    bool paletteAnim;
    ubyte colorLowerLimit;
    ubyte colorUpperLimit;
    word numOfColorSteps;
    word animSpeed;
    
    byte numOfColors;
    
    ulword lengthInBytes;
    ulword imageDataOffset;    // Zero :- unable to identify raw data
} UniversalPictureFormat;

/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
extern "C" {
#endif

UniversalPictureFormat getUniversalPictureFormat(const void *rawData, long unsigned int length);

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif /* UniversalPictureFormat_h */
