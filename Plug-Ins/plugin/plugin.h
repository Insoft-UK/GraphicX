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

#ifndef plugin_h
#define plugin_h

#include "common.h"
#include "endian.h"
#include "base64.h"

#pragma pack(1)     /* set alignment to 1 byte boundary */

typedef struct {
    char id[8]; // "Plug-In"
    uint16_t width;
    uint16_t height;
    uint8_t  type;          // 0: 256 Color Indexed(256 RGBA Palette + Pixel Data)  1: 24 16.7 Million Colors  2: 32-bit 16.7 Million Colors
    unsigned long length;   // Length of data in bytes that follow the header data.
}PlugInHeader;

typedef struct {
    PlugInHeader header;
    void *bytes;
} PlugIn;

typedef struct {
    unsigned long length;
    void *bytes;
} Data;

#pragma pack()   /* restore original alignment from stack */


/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
extern "C" {
#endif

Data dataWithContentsOfFile(const char *file);
Data dataWithCapacity(unsigned long numberOfBytes);
void dataDealloc(Data *data);
void plugInDealloc(PlugIn *plugin);
PlugIn plugInWithContentsOfData(const Data *data);
bool outputPlugInAsBase64(const PlugIn *plugin);

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif /* plugin_h */
