/*
Copyright © 2020 Insoft. All rights reserved.

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

#include "pbm.h"

#include <stdio.h>
#include <stdlib.h>

void loadPortableBitmapData(const char *filepath, void *dest) {
    FILE *fp;
    size_t len;
    char *line;
    char magic[2];
    int width = 0;
    int height = 0;
    
    fp = fopen(filepath, "rb");
    if (fp == NULL) return;
    
    fread(magic, sizeof(char), 2, fp);
    
    if (magic[0] == 'P' && magic[1] == '4') {
        // PBM :- Portable Bitmap Format (Binary)
        
        fseek(fp, 3, SEEK_SET);
        
        line = fgetln(fp, &len);
        if (line) {
            // width
            *(line + (len - 1)) = '\0';
            width = atoi(line) / 8;
        }
        
        line = fgetln(fp, &len);
        if (line) {
            // height
            *(line + (len - 1)) = '\0';
            height = atoi(line);
        }
        
        if (width > 0 && height > 0) {
            dest = malloc(width * height);
            if (dest != NULL) {
                fread(dest, sizeof(char), width * height / 8, fp);
            }
        }
    }
    fclose(fp);
}

bool saveAsPortableBitmapImage(const char *filepath, const void *src, int width, int height) {
    FILE *fp;
    fp = fopen(filepath, "wb");
    if (fp == NULL) return false;
    
    // PBM :- Portable Bitmap Format (Binary)
    fprintf(fp, "P4\n%d\n%d\n", width, height);
    fwrite(src, sizeof(char), width * height / 8, fp);
    
    fclose(fp);
    return true;
}
