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

#include "bmp.h"

#include <stdio.h>
#include <stdlib.h>

#pragma pack(1)     /* set alignment to 1 byte boundary */

/* Windows 3.x bitmap file header */
typedef struct {
    char        fileType[2];   /* magic - always 'B' 'M' */
    uint32_t    fileSize;
    int32_t     _reserved;
    uint32_t    dataOffset;    /* offset in bytes to actual bitmap data */
} BMPHeader;

/* Windows 3.x bitmap full header, including file header */

typedef struct {
    BMPHeader   fileHeader;
    uint32_t    biSize;
    int32_t     biWidth;
    int32_t     biHeight;
    int16_t     biPlanes;           // Number of colour planes, set to 1
    int16_t     biBitCount;         // Colour bits per pixel. 1 4 8 or 24
    uint32_t    biCompression;      // *Code for the compression scheme
    uint32_t    biSizeImage;        // *Size of the bitmap bits in bytes
    int32_t     biXPelsPerMeter;    // *Horizontal resolution in pixels per meter
    int32_t     biYPelsPerMeter;    // *Vertical resolution in pixels per meter
    uint32_t    biClrUsed;          // *Number of colours defined in the palette
    uint32_t    biClImportant;      // *Number of important colours in the image
} BIPHeader;

#pragma pack()   /* restore original alignment from stack */


void loadBitmapData(const char *filepath, void *dest) {
    FILE *fp;
    BIPHeader bip_header;
   
    fp = fopen(filepath, "rb");
    if (fp == NULL) return;
    
    fread(&bip_header, sizeof(BIPHeader), 1, fp);
    
    if (bip_header.biBitCount != 8) {
        fclose(fp);
    }
    
    dest = malloc(bip_header.biSizeImage - 2);
    if (dest == NULL) {
        fclose(fp);
        return;
    }
    
    // load in pixmap data from bottom upwards, fliping the image vertaly
    int bytesPerLine = bip_header.biWidth;
    
    fseek(fp , -(bytesPerLine + 2), SEEK_END);
    uint8_t *p = (uint8_t *)dest;
    for (int y=0; y<bip_header.biHeight; y++) {
        fread(p, sizeof(uint8_t), bytesPerLine, fp);
        
        p+=(bytesPerLine);
        fseek(fp, -(bytesPerLine * 2), SEEK_CUR);
    }
    
    fclose(fp);
}

bool saveAsBitmapImage(const char *filepath, const void *src, int width, int height, void *pal) {
    FILE *fp;
    fp = fopen(filepath, "wb");
    if (fp == NULL) return false;
    
    BIPHeader bipHeader = {
        .fileHeader = {
            .fileType = {'B','M'},
            .fileSize = 320 * 200 + sizeof(BIPHeader) + sizeof(uint16_t) + 64,
            ._reserved = 0,
            .dataOffset = sizeof(BIPHeader) + 48 + 16
        },
        .biSize = sizeof(BIPHeader) - sizeof(BMPHeader),
        .biWidth = width,
        .biHeight = height,
        .biPlanes = 1,
        .biBitCount = 8,
        .biCompression = 0,
        .biSizeImage = width * height + 2,
        .biXPelsPerMeter = 2834,
        .biYPelsPerMeter = 2834,
        .biClrUsed = 16,
        .biClImportant = 16
    };
    
    // PBM :- Portable Bitmap Format (Binary)
    fwrite(&bipHeader, sizeof(BIPHeader), 1, fp);
    
    // RGBA -> BGRx
    uint32_t *palettes = (uint32_t *)pal;
    for (int n=0; n < 16; n++) {
        uint8_t *channel = (uint8_t *)&palettes[n];
        fputc(channel[2], fp);
        fputc(channel[1], fp);
        fputc(channel[0], fp);
        fputc(0, fp);
    }
    
    uint8_t *bytes = (uint8_t *)src;
   
    for (int r = height - 1; r >= 0; r--) {
        for (int c=0; c<width; c+=16) {
            uint16_t *bitplanes = (uint16_t *)&bytes[c / 2 + r * (width / 2)];
            //bytes+=8;
            
            for (int n=15; n >= 0; n--) {
                int i = 0;
                for (int p=0; p<4; p++) {
                    uint16_t bitplane = bitplanes[p] >> 8 | bitplanes[p] << 8;
                    if (bitplane & (1 << n)) {
                        i |= (1 << p);
                    }
                }
                fputc(i, fp);
            }
                
            
        }
    }
    
    fputc(0, fp);
    fputc(0, fp);
    
    fclose(fp);
    return true;
}
