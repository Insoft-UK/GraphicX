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

#include "plugin.h"

#pragma pack(1)     /* set alignment to 1 byte boundary */

typedef struct {
    int16_t resolution;     /*
                             resolution [0 = low res, 1 = medium res, 2 = high res]
                             Other bits may be used in the future; use a simple bit
                             test rather than checking for specific word values.
                             */
    
    int16_t palette[16];
} Degas;

typedef struct {
    uint16_t plane[4];
} Bitplanes;

#pragma pack()   /* restore original alignment from stack */

bool isDegasFormat(const void *rawData, long unsigned int length);


int main(int argc, const char * argv[]) {
    if (argc == 1) {
        //return -10;
    }
    
#if DEBUG
    argv[1] = "/Users/richie/Documents/GitHub/GraphicX/Pictures/Degas/OCEAN.PI1";
#endif
    
    Data data = dataWithContentsOfFile(argv[1]);
    if (data.bytes == NULL) return -1;
    

    // Process the raw data
    
    Data mutableData;
    
    if (isDegasFormat(data.bytes, data.length)) {
        Degas *degas_ref = data.bytes;
        
        mutableData = dataWithCapacity(320 * 200 + 1024);
        
        if (mutableData.bytes == NULL) {
            dataDealloc(&data);
            return  -2;
        }
        
        mutableData.length = 320 * 200 + 1024;
        
        
        // Palette
        uint32_t *pal = mutableData.bytes;
        for (int i=0; i<256; i++) {
            if (i < 16) {
                uint32_t color;
                if (isAtariSteFormat((uint16_t *)degas_ref->palette) == true) {
                    color = colorFrom12BitRgb(degas_ref->palette[i]);
                } else {
                    color = colorFrom9BitRgb(degas_ref->palette[i]);
                }
                
                pal[i] = color;
            } else {
                pal[i] = 0;
            }
        }
        
        // Image :- Convert to 256 Color Indexed Format
        uint8_t *dst = mutableData.bytes + 1024;
        
        Bitplanes *bitplanes = (Bitplanes *)(data.bytes + data.length - 32000);
        
        for (int r=0; r<200; ++r) {
            for (int c=0; c<320; c+=16) {
                
                for (int n=15; n >= 0; n--) {
                    int colorIndex = 0;
                    
                    for (int p=0; p<4; p++) {
                        uint16_t plane = bitplanes->plane[p];
#ifdef __LITTLE_ENDIAN__
                        plane = swapInt16BigToHost(plane);
#endif
                        if (plane & (1 << n)) {
                            colorIndex |= (1 << p);
                        }
                    }
                    *dst++ = colorIndex;
                }
                bitplanes++;
            }
        }
    }
        
    
    dataDealloc(&data);
    
    // Output the mutableData as base64 text!
    PlugIn plugin = plugInWithContentsOfData(&mutableData);
    dataDealloc(&mutableData);
    
    if (plugin.bytes != NULL) {
        outputPlugInAsBase64(&plugin);
        plugInDealloc(&plugin);
    }
    
    
    return 0;
}

bool isDegasFormat(const void *rawData, long unsigned int length) {
    if (length != 32034) { /// A Degas file will always be exacly 32,034 bytes in length.
        if (length != 32066) { /// DEGAS Elite file will always be exacly 32,066 bytes in length.
            return false;
        } else {
            // DEGAS Elite
            // TODO: Palette Animation...
            
        }
    }
    
    const Degas *degas_ref = (Degas *)rawData;
    if ((swapInt16BigToHost(degas_ref->resolution) & 3) == 3) return false;
 
    return true;
}

