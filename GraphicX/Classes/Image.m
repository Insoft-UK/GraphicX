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

#import "Image.h"

@implementation Image

// MARK: - Public Class Methods

+ (CGImageRef)createCGImage:(CGSize)size ofPixelData:(const void *)pixelData {
    static const size_t kComponentsPerPixel = 4;
    static const size_t kBitsPerComponent = sizeof(unsigned char) * 8;
    
    NSInteger layerWidth = size.width;
    NSInteger layerHeight = size.height;
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    size_t bufferLength = layerWidth * layerHeight * kComponentsPerPixel;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixelData, bufferLength, NULL);
    CGImageRef imageRef = CGImageCreate(layerWidth, layerHeight, kBitsPerComponent,
                                        kBitsPerComponent * kComponentsPerPixel,
                                        kComponentsPerPixel * layerWidth,
                                        rgb,
                                        kCGBitmapByteOrderDefault | kCGImageAlphaLast,
                                        provider, NULL, false,kCGRenderingIntentDefault);
    

    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgb);
    
    return imageRef;
}

+ (BOOL)writeCGImage:(CGImageRef)image to:(NSURL *)destinationURL {
    if (image == nil) {
        return NO;
    }
    CFURLRef cfurl = (__bridge CFURLRef)destinationURL;
    
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL(cfurl, kUTTypePNG, 1, nil);
    CGImageDestinationAddImage(destinationRef, image, nil);
    return CGImageDestinationFinalize(destinationRef);
}


@end


