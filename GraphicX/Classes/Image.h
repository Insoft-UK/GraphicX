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

#import <CoreGraphics/CoreGraphics.h>

#ifndef Image_h
#define Image_h

@interface Image: SKNode

// MARK: - Class Properties

@property (readonly) CGSize size;
@property (readonly) UInt32 bitsPerPixel;       // When planeCount is equal to 1, bitsPerPixel is regarded as bitsPerPlane 8/16
@property (readonly) UInt32 planeCount;         // Packed if value == 0, else Planar
@property BOOL alphaPlane;
@property (readonly) Palette *palette;
@property (readonly) NSData* data;

// MARK: - Class Init

-(id)initWithSize:(CGSize)size;

// MARK: - Class Instance Methods

- (void)firstAtariSTPalette;
- (void)nextAtariSTPalette;
-(void)modifyWithContentsOfURL:(NSURL*)url;
-(void)nextDataBlock;
-(void)previousDataBlock;
-(void)decreaseBySingleLine;
-(void)increaseBySingleLine;
-(void)decreaseByBytes:(NSUInteger)bytes;
-(void)increaseByBytes:(NSUInteger)bytes;
-(void)updateWithDelta:(NSTimeInterval)delta;
-(void)home;
-(void)end;
-(void)saveImageAtURL:(NSURL *)url;


// MARK: - Class Methods

+ (CGImageRef)createCGImage:(CGSize)size ofPixelData:(const void *)pixelData;
+ (BOOL)writeCGImage:(CGImageRef)image to:(NSURL *)destinationURL;

// MARK:- Class Getter & Setters

- (void)setBitsPerPixel:(UInt32)bitsPerPixel;
- (void)setPlaneCount:(UInt32)planeCount;
- (void)setSize:(CGSize)size;

@end


#endif /* Image_h */
