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

#import <SpriteKit/SpriteKit.h>

typedef enum {
    PixelArrangementPlanar,
    PixelArrangementPacked
} PixelArrangement;

@interface MainScene : SKScene

// MARK: - Class Properties

@property (readonly) PixelArrangement pixelArrangement;
//@property (readonly) NSInteger bytesPerBitplane;

@property (readonly) UInt32 bitsPerComponent;
@property (readonly) UInt32 bitsPerPlane;
@property (readonly) UInt32 planeCount;

@property (readonly) CGSize screenSize;
@property (readonly) BOOL maskInterleaved;

// MARK: - Class Instance Methods

- (void)nextPalette;
- (void)openDocument;
- (void)importPalette;
- (void)exportAs;
- (void)exportPalette;
- (void)increaseWidth;
- (void)decreaseWidth;

// MARK:- Class Getter & Setters

- (void)setBitsPerComponent:(UInt32)bitsPerComponent;
- (void)setBitsPerPlane:(UInt32)bitsPerPlane;
- (void)setPlaneCount:(UInt32)planeCount;
- (void)setMaskInterleaved:(BOOL)maskInterleaved;

- (void)setPixelArrangement:(PixelArrangement)pixelArrangement;

- (void)setScreenSize:(CGSize)size;

@end
