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

#import "MainScene.h"

#import "GraphicX-Swift.h"



#import <Cocoa/Cocoa.h>

#define MAX_DATA_BUFFER_SIZE    65536




UInt32 _palette[256] = {
    0xff000000, 0xff111111, 0xff222222, 0xff333333, 0xff444444, 0xff555555, 0xff666666, 0xff777777,
    0xff888888, 0xff999999, 0xffaaaaaa, 0xffbbbbbb, 0xffcccccc, 0xffdddddd, 0xffeeeeee, 0xffffffff
};

@interface MainScene()

@property (nonatomic) SKMutableTexture *mutableTexture;
@property (nonatomic) NSData *data;
@property (readonly) NSInteger dataOffset;
@property (readonly) NSInteger paletteOffset;

@property RawData *rawData;

@property SKSpriteNode *imageNode;
@property Palette *palette;


@end

@implementation MainScene

// MARK: - View

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    [self setup];
    
    Singleton.sharedInstance.mainScene = self;
}

- (void)willMoveFromView:(SKView *)view {
    
}

// MARK: - Setup

- (void)setup {
    self.bitsPerPixel = 16;
    self.planeCount = 4;
    self.dataOffset = 0;
    self.paletteOffset = 0;
    self.alphaPlane = NO;
    
    [self setScreenSize:CGSizeMake(320, 200)];
    
    self.palette = [[Palette alloc] init];
    Singleton.sharedInstance.palette = self.palette;
    
    self.size = CGSizeMake(720, 576);
    
    self.rawData = [[RawData alloc] init];
    self.rawData.offset = 0;
    
    // TODO: Code refactoring...
    
    self.mutableTexture = [SKMutableTexture mutableTextureWithSize:CGSizeMake(720, 576)];
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        memset(pixelData, 0x0, lengthInBytes);
    }];
    self.mutableTexture.filteringMode = SKTextureFilteringNearest;
    self.imageNode = [SKSpriteNode spriteNodeWithTexture:self.mutableTexture];
    
    self.imageNode = [SKSpriteNode spriteNodeWithTexture:self.mutableTexture];
    self.imageNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.imageNode.yScale = -1;
    
    
    [self addChild:self.imageNode];
    
    
}


// MARK: - Touch Events

/*
- (void)touchDownAtPoint:(CGPoint)pos {
    
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
}

- (void)touchUpAtPoint:(CGPoint)pos {
   
}
*/

// MARK: - Keyboard Events

- (void)keyDown:(NSEvent *)theEvent {
    
    UInt32 height = (UInt32)self.screenSize.height;
    
    NSUInteger flags = [theEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
    if( flags == NSEventModifierFlagCommand ){
        switch (theEvent.keyCode) {
            case 0x0D: // W
                self.dataOffset = 0;
                break;
                
            case 0x01: // S
                self.dataOffset = (UInt32)self.data.length - [self bytesPerLine] * height;
                break;
        }
    } else {
        switch (theEvent.keyCode) {
            case 0x02: // D
                self.dataOffset += self.bitsPerPixel * self.planeCount / 8;
                break;
                
            case 0x00: // A
                self.dataOffset -= self.bitsPerPixel * self.planeCount / 8;
                break;
                
            case 0x0D: // W
                self.dataOffset -= [self bytesPerLine] * 8;
                break;
                
            case 0x01: // S
                self.dataOffset += [self bytesPerLine] * 8;
                break;
                
            case 0x24 /* ENTER  */:
                self.dataOffset += [self bytesPerLine] * height;
                break;
                
                
            case 0x33 /* BACKSPACE  */:
                self.dataOffset -= [self bytesPerLine] * height;
                break;
                
                
            case 0x35 /* ESC */:
                self.dataOffset = 0;
                self.paletteOffset = 0;
                break;
                
            case 0x7b /* CURSOR LEFT */:
                
                self.dataOffset--;
                break;
                
            case 0x7c /* CURSOR RIGHT */:
                self.dataOffset++;
                break;
                
            case 0x7d /* CURSOR DOWN */:
                self.dataOffset += [self bytesPerLine];
                break;
                
            case 0x7e /* CURSOR UP */:
                self.dataOffset -= [self bytesPerLine];
                break;
                
                
            default:
#ifdef DEBUG
                NSLog(@"keyDown:'%@' keyCode: 0x%02X", theEvent.characters, theEvent.keyCode);
#endif
                break;
        }
        
    }
    
    
    
    
}

// MARK: - Mouse Events

/*
- (void)mouseDown:(NSEvent *)theEvent {
    [self touchDownAtPoint:[theEvent locationInNode:self]];
}
- (void)mouseDragged:(NSEvent *)theEvent {
    [self touchMovedToPoint:[theEvent locationInNode:self]];
}
- (void)mouseUp:(NSEvent *)theEvent {
    [self touchUpAtPoint:[theEvent locationInNode:self]];
}
*/

// MARK: - Update

-(void)update:(CFTimeInterval)currentTime {
    static NSUInteger previousDataOffset = 0;
    
    if (previousDataOffset != self.dataOffset) {
        [self modifyMutableTexture];
    }
    
    previousDataOffset = self.dataOffset;
}

- (void)modifyMutableTexture {
    if (self.data == nil) {
        [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
            UInt32 *pixels = (UInt32 *)pixelData;
            while (lengthInBytes -= 4) {
                *pixels = 0;
            }
        }];
        return;
    }
    
    self.dataOffset = self.dataOffset; // Will perform a check when set, so we can be sure the offset is allways valid.
    
    NSInteger height = (NSInteger)self.screenSize.height;
    [self modifyTextureWithData: self.data rangeFrom:self.dataOffset to: [self bytesPerLine] * height + self.dataOffset];
    
}

// Modify texure pixel data from raw data that is atari st bitmap graphics.
- (void)modifyTextureWithData:(const NSData *) data rangeFrom:(size_t)from to:(size_t)to {
    if (to < from) return;
   
    [self setDataOffset:self.dataOffset]; // Will result dataOffset being validated.
    
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        UInt32 *pixel = (UInt32 *)pixelData;
        UInt8 *bytes = (UInt8 *)data.bytes;
        
        bytes += from;
        int planeCount = self.alphaPlane == YES ? (int)self.planeCount + 1 : (int)self.planeCount;
      
        int height = (int)self.screenSize.height;
        int width = (int)self.screenSize.width;
        
        int w = (int)self.mutableTexture.size.width;
        int lines = (int)self.mutableTexture.size.height;
        
        for (int r = -(lines - height) / 2; r < (height + (lines - height) / 2); ++r) {
            if (r < 0 || r >= height) {
                for (int c = 0; c < w; ++c) {
                    *pixel++ = 0;
                }
            } else {
                for (int c = -(w - width) / 2; c < (width + (w - width) / 2); ++c) {
                    if (c < 0 || c >= width) {
                        *pixel++ = 0;
                    }
                    else {
                        if (self.planeCount > 1) {
                            // Planer
                            
                            if (self.bitsPerPixel == 8) {
                                UInt8 *planeData = (UInt8 *)bytes;
                                if (self.alphaPlane == YES) {
                                    for (int n=(int)self.bitsPerPixel - 1; n >= 0; n--) {
                                        UInt8 plane = *planeData;

                                        if (plane & (1 << n)) {
                                            pixel[self.bitsPerPixel - 1 - n] = 0;
                                        } else {
                                            pixel[self.bitsPerPixel - 1 - n] = 0xFF000000;
                                        }
                                    }
                                    bytes += 1;
                                }
                                for (int n=7; n >= 0; n--) {
                                    int i = 0;
                                    for (int p=0; p<planeCount; p++) {
                                        UInt8 plane = planeData[p];
                                        if (plane & (1 << n)) {
                                            i |= (1 << p);
                                        }
                                    }
                                    
                                    *pixel++ = planeCount > 1 ? [self.palette getRgbColorAtIndex:i] : (0xFFFFFF * i) | 0xFF000000;
                                }
                            } else {
                                UInt16 *planeData = (UInt16 *)bytes;
                                if (self.alphaPlane == YES) {
                                    for (int n=(int)self.bitsPerPixel - 1; n >= 0; n--) {
                                        UInt16 plane = *planeData;
#ifdef __LITTLE_ENDIAN__
                                        plane = CFSwapInt16BigToHost(plane);
#endif
                                        if (plane & (1 << n)) {
                                            pixel[self.bitsPerPixel - 1 - n] = 0;
                                        } else {
                                            pixel[self.bitsPerPixel - 1 - n] = 0xFF000000;
                                        }
                                    }
                                    bytes += self.bitsPerPixel / 8;
                                }
                                for (int n=(int)self.bitsPerPixel - 1; n >= 0; n--) {
                                    int colorIndex = 0;
                                    
                                    for (int p=0; p<(int)self.planeCount; p++) {
                                        UInt16 plane = planeData[p];
#ifdef __LITTLE_ENDIAN__
                                        plane = CFSwapInt16BigToHost(plane);
#endif
                                        if (plane & (1 << n)) {
                                            colorIndex |= (1 << p);
                                        }
                                    }
                                    UInt32 color = [self.palette getRgbColorAtIndex:colorIndex];
                                    if (self.alphaPlane == YES && colorIndex == 0) {
                                        color &= 0x00FFFFFF;
                                    }
                                    *pixel = self.planeCount > 1 ? color : (0xFFFFFF * colorIndex) | 0xFF000000;
                                    pixel++;
                                }
                            }
                            
                            c += self.bitsPerPixel - 1;
                            bytes += self.bitsPerPixel / 8 * self.planeCount;
                        } else {
                            // Packed
                            
                            switch (self.bitsPerPixel) {
                                case 24: // 16.7 Million Colors
                                    {
                                        UInt32 trueColor = 0;
                                        trueColor |= (UInt32)bytes[0];
                                        trueColor |= (UInt32)bytes[1] << 8;
                                        trueColor |= (UInt32)bytes[2] << 16;
                                        trueColor |= 0xFF000000;
                                        *pixel++ = trueColor;
                                    }
                                    bytes += 3;
                                    break;
                                    
                                case 8: // 8-Bit Index Color
                                    *pixel++ = [self.palette getRgbColorAtIndex:*bytes];
                                    bytes += 1;
                                    break;
                                    
                                case 4: // 4-Bit Index Color
                                    *pixel++ = [self.palette getRgbColorAtIndex:bytes[0] >> 4];
                                    *pixel++ = [self.palette getRgbColorAtIndex:bytes[0] & 0b1111];
                                    bytes += 1;
                                    c += 1;
                                    break;
                                    
                                case 2: // 2-Bit Index Color
                                    *pixel++ = [self.palette getRgbColorAtIndex:bytes[0] >> 6];
                                    *pixel++ = [self.palette getRgbColorAtIndex:(bytes[0] >> 4) & 0b11];
                                    *pixel++ = [self.palette getRgbColorAtIndex:(bytes[0] >> 2) & 0b11];
                                    *pixel++ = [self.palette getRgbColorAtIndex:bytes[0] & 0b11];
                                    bytes += 1;
                                    c += 3;
                                    break;
                                    
                                case 1:
                                    for (int n=0; n<8; n++) {
                                        if (*bytes & (1 << n)) {
                                            *pixel++ = 0xFFFFFFFF;
                                        } else {
                                            *pixel++ = 0xFF000000;
                                        }
                                    }
                                    bytes += 1;
                                    c += 7;
                                    break;
                                    
                                default:
                                    bytes += 1;
                                    break;
                            }
                            
                            
                        }
                    }
                }
            }
        }
        /*
        pixel = (UInt32 *)pixelData + lengthInBytes - 1 - w * 8;
        for (int r = lines - 8; r < lines; r++) {
            for (int c = 0; c < w; c++) {
                *pixel++ = [self.palette getRgbColorAtIndex:c / (w / 16)];
            }
        }
         
         */
    }];
    
    
}


// MARK: - Class Public Methods

- (void)nextPalette {
    [self findAtariSTPaletteFromData:self.data];
    [self modifyMutableTexture];
}

- (void)openDocument {
    NSURL *url;
    
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.title = @"GraphicX";
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = NO;
    
    NSModalResponse modalResponse = [openPanel runModal];
    if (modalResponse == NSModalResponseOK) {
        url = openPanel.URL;
        if (url != nil) {
            self.data = [NSData dataWithContentsOfURL:url];
            
            if (self.data == nil) {
                NSLog(@"ERROR! No Data");
            } else {
                
                UniversalPictureFormat upf = getUniversalPictureFormat(self.data.bytes, self.data.length);
                if (upf.pictureDataOffset != 0) {
                    [self setPlaneCount:upf.planeCount];
                    self.bitsPerPixel = upf.bitsPerPixel;
                    [self setScreenSize:CGSizeMake(upf.width, upf.height)];
                    self.dataOffset = (UInt32)upf.pictureDataOffset;
                    for (int i=0; i<256; i++) {
                        [self.palette setRgbColor:upf.palette[i] atIndex:i];
                    }
                } else {
                    self.dataOffset = 0;
                }

                
                
                [self modifyMutableTexture];
            }
        }
    }
    
    
}

- (void)importPalette {
    NSURL *url;
    
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.title = @"GraphicX";
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = NO;
    
    NSModalResponse modalResponse = [openPanel runModal];
    if (modalResponse == NSModalResponseOK) {
        url = openPanel.URL;
        if (url != nil) {
            [self.palette loadWithContentsOfFile:url.path];
            [self modifyMutableTexture];
        }
    }
    
    
}

- (void)exportAs {
    NSURL *url;
    
    NSSavePanel *savePanel = [[NSSavePanel alloc] init];
    savePanel.title = @"GraphicX";
    savePanel.canCreateDirectories = YES;
    savePanel.nameFieldStringValue = @"GraphicX.png";
    
    NSModalResponse modalResponse = [savePanel runModal];
    if (modalResponse == NSModalResponseOK) {
        url = savePanel.URL;
        if (url != nil) {
            [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
                CGImageRef imageRef = [Image createCGImage:self.mutableTexture.size ofPixelData:pixelData];
                [Ximage writeCGImage:CGImageCreateWithImageInRect(imageRef, CGRectMake((self.mutableTexture.size.width - self.screenSize.width) / 2, (self.mutableTexture.size.height - self.screenSize.height) / 2, self.screenSize.width, self.screenSize.height)) to:savePanel.URL];
                CGImageRelease(imageRef);
            }];
        }
    }
}

- (void)exportPalette {
    NSURL *url;
    
    NSSavePanel *savePanel = [[NSSavePanel alloc] init];
    savePanel.title = @"GraphicX";
    savePanel.canCreateDirectories = YES;
    savePanel.nameFieldStringValue = @"palette.act";
    
    NSModalResponse modalResponse = [savePanel runModal];
    if (modalResponse == NSModalResponseOK) {
        url = savePanel.URL;
        if (url != nil) {
            [self.palette saveAsPhotoshopActAtPath:url.path];
        }
    }
}

- (void)zoomIn {
    if (self.imageNode.xScale < 8.0) {
        self.imageNode.xScale = self.imageNode.xScale + 1.0;
        self.imageNode.yScale = -self.imageNode.xScale;
    }
}
- (void)zoomOut {
    if (self.imageNode.xScale > 1.0) {
        self.imageNode.xScale = self.imageNode.xScale - 1.0;
        self.imageNode.yScale = -self.imageNode.xScale;
    }
}


// MARK:- Public Getter & Setters

- (void)setBitsPerPixel:(UInt32)bitsPerPixel {
    _bitsPerPixel = bitsPerPixel > 0 ? bitsPerPixel : 1;
    if (self.planeCount > 1) {
        _bitsPerPixel = _bitsPerPixel > 7 ? _bitsPerPixel & 0xF8 : 8;
    }
    [self modifyMutableTexture];
}

- (void)setPlaneCount:(UInt32)planeCount {
    _planeCount = planeCount >= 0 ? planeCount : 1;
    [self.palette setColorCount:2 ^ self.planeCount];
    if (planeCount == 1 && planeCount != 0) {
        self.alphaPlane = NO;
    }
    [self modifyMutableTexture];
}

- (void)setScreenSize:(CGSize)size {
    _screenSize = size;
    if (self.screenSize.width < self.bitsPerPixel) {
        _screenSize.width = self.bitsPerPixel;
    }
    if (self.screenSize.width > self.mutableTexture.size.width) {
        _screenSize.width = self.mutableTexture.size.width;
    }
    if (self.screenSize.height < 8.0) {
        _screenSize.height = 8.0;
    }
    if (self.screenSize.height > self.mutableTexture.size.height) {
        _screenSize.height = self.mutableTexture.size.height;
    }
    [self modifyMutableTexture];
}

- (void)setAlphaPlane:(BOOL)alphaPlane {
    _alphaPlane = alphaPlane;
    [self modifyMutableTexture];
}


// MARK:- Private Getter & Setters

- (void)setDataOffset:(NSInteger)dataOffset {
    if (_dataOffset + dataOffset < 0) {
        _dataOffset = 0;
    } else {
        _dataOffset = dataOffset + [self bytesPerLine] * (UInt32)self.screenSize.height < self.data.length ? dataOffset : self.data.length - [self bytesPerLine] * (UInt32)self.screenSize.height;
    }
}


- (void)setPaletteOffset:(NSInteger)paletteOffset {
    _paletteOffset = paletteOffset < self.data.length ? paletteOffset : paletteOffset -self.data.length;
}

// MARK:- Private Class Methods

- (UInt32)bytesPerLine {
    if (self.planeCount == 1) {
        return ( UInt32 )self.screenSize.width * ((self.bitsPerPixel + 7) & 0xF80);
    } else {
        return ( UInt32 )self.screenSize.width / self.bitsPerPixel * ( self.bitsPerPixel / 8 * (self.alphaPlane == YES ? self.planeCount + 1 : self.planeCount) );
    }
}


- (void)findAtariSTPaletteFromData:(const NSData *) data  {
    UInt8 *bytes = (UInt8 *)data.bytes;
    bytes += self.paletteOffset;
    NSUInteger lengthInBytes = data.length - 32 - self.paletteOffset;
    
    
    while (lengthInBytes--) {
        UInt16* pal = ( UInt16* )bytes;
        
        if ([Palette isAtariSteFormat:( UInt16* )bytes] == YES) {
            for (int i=0; i<16; i++) {
                [self.palette setRgbColor:[Palette colorFrom12BitRgb:pal[i]] atIndex:i];
            }
            break;
        } else if ([Palette isAtariStFormat:( UInt16* )bytes] == YES) {
            for (int i=0; i<16; i++) {
                [self.palette setRgbColor:[Palette colorFrom9BitRgb:pal[i]] atIndex:i];
            }
            break;
        }

        self.paletteOffset++;
        bytes++;
    }
    
    self.paletteOffset++;
    if (self.paletteOffset + 32 >= data.length) {
        self.paletteOffset = 0;
    }
    
    
}




@end
