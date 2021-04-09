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


#include "common.h"

bool isAnyRepeatsInList( const uint16_t* list, unsigned long length);

// Atari ST  :- xx xx xx xx xx R2 R1 R0  xx G2 G1 G0 xx B2 B1 B0 (be)
uint32_t colorFrom9BitRgb( uint16_t rgb) {
    uint32_t color;
#ifdef __LITTLE_ENDIAN__
    rgb = swapInt16BigToHost(rgb);
#endif
    // xx C2 C1 C3 -> C2 C1 C0 [C2 | C1]
    rgb = ( ( rgb & 0x777 ) << 1 ) | ( ( rgb & 0x444 ) >> 2 ) | ( ( rgb & 0x222 ) >> 1 );
    color = ( ( uint32_t )( rgb & 0x0F00 ) >> 4 ) | ( ( uint32_t )( rgb & 0x00F0 ) << 8 ) | ( ( uint32_t )( rgb & 0x000F ) << 20 );
    return  color | ( color >> 4 ) | 0xFF000000;
}

// Atari STE :- xx xx xx xx R0 R3 R2 R1  G0 G3 G2 G1 B0 B3 B2 B1
uint32_t colorFrom12BitRgb( uint16_t rgb) {
    uint32_t color;
#ifdef __LITTLE_ENDIAN__
    rgb = swapInt16BigToHost(rgb);
#endif
    // C0 C3 C2 C1 -> C3 C2 C1 C0
    rgb = ( ( rgb & 0x777 ) << 1 ) | ( ( rgb & 0x888 ) >> 3 );
    color = ( ( uint32_t )( rgb & 0x0F00 ) >> 4 ) | ( ( uint32_t )( rgb & 0x00F0 ) << 8 ) | ( ( uint32_t )( rgb & 0x000F ) << 20 );
    return  color | ( color >> 4 ) | 0xFF000000;
}

bool isAtariStFormat( const uint16_t* rgb) {
    uint16_t color;
    
    for ( int i=0; i < 16; i++) {
        color = rgb[i];
#ifdef __LITTLE_ENDIAN__
        color = swapInt16BigToHost(color);
#endif
        if ( color & 0b1111100010001000 ) return false;
    }
    
    return !isAnyRepeatsInList(rgb, 16);
}


bool isAtariSteFormat( const uint16_t* rgb) {
    uint16_t color;

    for ( int i=0; i < 16; i++) {
        color = rgb[i];
#ifdef __LITTLE_ENDIAN__
        color = swapInt16BigToHost(color);
#endif
        if ( color & 0b1111000000000000 ) return false;
    }
    
    return !isAnyRepeatsInList(rgb, 16);
}

bool isAnyRepeatsInList( const uint16_t* list, unsigned long length) {
    for (unsigned long i = 0; i < length; i++) {
        for (unsigned long j = 0; j < length; j++) {
            if (i != j) {
                if (list[i] == list[j]) {
                    return true;
                }
            }
        }
    }
    return false;
}
