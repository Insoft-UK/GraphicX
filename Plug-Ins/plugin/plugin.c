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

Data dataWithContentsOfFile(const char *file) {
    FILE *fp;
    Data data = {
        .length = 0,
        .bytes = NULL
    };
    
    if ((fp = fopen(file, "rb")) != NULL) {
        fseek(fp, 0, SEEK_END);
        size_t size = ftell(fp);
        fseek(fp, 0, SEEK_SET);
        
        void *bytes = malloc(size);
        if (bytes != NULL) {
            data.bytes = bytes;
            data.length = size;
            return data;
        }
    }
    return data;
}

Data dataWithCapacity(unsigned long numberOfBytes) {
    Data data = {
        .length = 0,
        .bytes = NULL
    };
    
    data.bytes = malloc(numberOfBytes);
    return data;
}

void dataDealloc(Data *data) {
    if (data != NULL) {
        if (data->bytes != NULL) {
            free(data->bytes);
            data->bytes = NULL;
            data->length = 0;
        }
    }
}

void plugInDealloc(PlugIn *plugin) {
    if (plugin != NULL) {
        if (plugin->bytes != NULL) {
            free(plugin->bytes);
            plugin->bytes = NULL;
            plugin->header.length = 0;
        }
    }
}

PlugIn plugInWithContentsOfData(const Data *data) {
    PlugIn plugin = {
        .header = {
            .id = "Plug-In",
            .width = 16,
            .height = 1,
            .length = data->length
        },
        .bytes = NULL
    };
    
    if (data == NULL || data->length == 0) return plugin;
    
    plugin.bytes = malloc(data->length);
    if (plugin.bytes != NULL) {
        memcpy(plugin.bytes, data->bytes, data->length);
    }
    
    return plugin;
}

static bool outputDataAsBase64(const Data *data) {
    if (data != NULL) {
        unsigned long length;
        char *p = base64_encode((unsigned char *)data->bytes, data->length, &length);
        if (length > 0) {
            printf("%s", p);
        }
    }
    return true;
}

bool outputPlugInAsBase64(const PlugIn *plugin) {
    if (plugin == NULL) return false;
    if (plugin->bytes == NULL) return false;
    
    Data data = dataWithCapacity(plugin->header.length + sizeof(PlugInHeader));
    if (data.bytes != NULL) {
        data.length = plugin->header.length;
        memcpy(data.bytes, &plugin->header, sizeof(PlugInHeader));
        memcpy(data.bytes + sizeof(PlugInHeader), plugin->bytes, plugin->header.length);
        
        outputDataAsBase64(&data);
        
        dataDealloc(&data);
        return true;
    }
    return false;
}

