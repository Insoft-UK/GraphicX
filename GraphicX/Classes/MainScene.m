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

@property Palette *palette;

//@property NSInteger bytesPerLine;



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
    self.bitsPerComponent = 8;
    self.bitsPerPlane = 16;
    self.planeCount = 4;
    self.dataOffset = 0;
    self.paletteOffset = 0;
    self.maskInterleaved = NO;
    
    [self setScreenSize:CGSizeMake(320, 200)];
    _pixelArrangement = PixelArrangementPlanar;

    self.palette = [[Palette alloc] init];
    
    self.size = CGSizeMake(720, 576);
    self.backgroundColor = [Colors colorFromRgb:bloodRed];

    
    self.mutableTexture = [SKMutableTexture mutableTextureWithSize:CGSizeMake(720, 576)];
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        memset(pixelData, 0x0, lengthInBytes);
    }];
    self.mutableTexture.filteringMode = SKTextureFilteringNearest;
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:self.mutableTexture];
    
    node = [SKSpriteNode spriteNodeWithTexture:self.mutableTexture];
    node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    node.yScale = -1;
    
    
    [self addChild:node];
    
    
}

// MARK: - Touch Events

- (void)touchDownAtPoint:(CGPoint)pos {
    
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
}

- (void)touchUpAtPoint:(CGPoint)pos {
   
}

// MARK: - Keyboard Events

- (void)keyDown:(NSEvent *)theEvent {
    
    NSInteger height = (NSInteger)self.screenSize.height;
    
    NSUInteger flags = [theEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
    if( flags == NSEventModifierFlagCommand ){
        switch (theEvent.keyCode) {
            case 0x0D: // W
                self.dataOffset = 0;
                break;
                
            case 0x01: // S
                self.dataOffset = self.data.length - [self bytesPerLine] * height;
                break;
        }
    } else {
        switch (theEvent.keyCode) {
            case 0x02: // D
                self.dataOffset += self.bitsPerPlane * self.planeCount / 8;
                break;
                
            case 0x00: // A
                self.dataOffset -= self.bitsPerPlane * self.planeCount / 8;
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

- (void)mouseDown:(NSEvent *)theEvent {
    [self touchDownAtPoint:[theEvent locationInNode:self]];
}
- (void)mouseDragged:(NSEvent *)theEvent {
    [self touchMovedToPoint:[theEvent locationInNode:self]];
}
- (void)mouseUp:(NSEvent *)theEvent {
    [self touchUpAtPoint:[theEvent locationInNode:self]];
}

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
    
    NSInteger height = (NSInteger)self.screenSize.height;
    [self modifyTextureWithData: self.data rangeFrom:self.dataOffset to: [self bytesPerLine] * height + self.dataOffset];
    
}

// Modify texure pixel data from raw data that is atari st bitmap graphics.
- (void)modifyTextureWithData:(const NSData *) data rangeFrom:(size_t)from to:(size_t)to {
    if (to < from) return;
   
    [self setDataOffset:self.dataOffset]; // Will result dataOffset being validated.
    
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        UInt32 *pixels = (UInt32 *)pixelData;
        UInt8 *bytes = (UInt8 *)data.bytes;
        
        bytes += from;
        int planeCount = (int)self.planeCount;
      
        int height = (int)self.screenSize.height;
        int width = (int)self.screenSize.width;
        
        int w = (int)self.mutableTexture.size.width;
        int lines = (int)self.mutableTexture.size.height;
        
        for (int r = -(lines - height) / 2; r < (height + (lines - height) / 2); ++r) {
            if (r < 0 || r >= height) {
                for (int c = 0; c < w; ++c) {
                    *pixels++ = [self.palette getRgbColorAtIndex:0];
                }
            } else {
                for (int c = -(w - width) / 2; c < (width + (w - width) / 2); ++c) {
                    if (c < 0 || c >= width) {
                        *pixels++ = [self.palette getRgbColorAtIndex:0];
                    }
                    else {
                        if (self.pixelArrangement == PixelArrangementPlanar) {
                            if (self.bitsPerPlane == 8) {
                                c+=7;
                                UInt8 *planes = (UInt8 *)bytes;
                                bytes += self.bitsPerPlane / 8 * planeCount;
                                
                                for (int n=7; n >= 0; n--) {
                                    int i = 0;
                                    for (int p=0; p<planeCount; p++) {
                                        UInt8 plane = planes[p];
                                        if (plane & (1 << n)) {
                                            i |= (1 << p);
                                        }
                                    }
                                    *pixels++ = [self.palette getRgbColorAtIndex:i];
                                }
                            } else {
                                c+=15;
                                UInt16 *planes = (UInt16 *)bytes;
                                bytes += self.bitsPerPlane / 8 * planeCount;
                                
                                for (int n=15; n >= 0; n--) {
                                    int i = 0;
                                    for (int p=0; p<planeCount; p++) {
                                        UInt16 plane = planes[p];
#ifdef __LITTLE_ENDIAN__
                                        plane = CFSwapInt16BigToHost(plane);
#endif
                                        if (plane & (1 << n)) {
                                            i |= (1 << p);
                                        }
                                    }
                                    *pixels++ = [self.palette getRgbColorAtIndex:i];
                                }
                            }
                        } else {
                            if (self.bitsPerComponent == 8 && self.pixelArrangement == PixelArrangementPacked) {
                                // Indexed Color
                                *pixels++ = [self.palette getRgbColorAtIndex:*bytes++];
                            }
                            
                            if (self.bitsPerComponent == 4 && self.pixelArrangement == PixelArrangementPacked) {
                                // 16 Colors
                                *pixels++ = [self.palette getRgbColorAtIndex:bytes[0] >> 4];
                                *pixels++ = [self.palette getRgbColorAtIndex:bytes[0] & 0b1111];
                                bytes++;
                            }
                            
                            if (self.bitsPerComponent == 2 && self.pixelArrangement == PixelArrangementPacked) {
                                // 4 Colors
                                *pixels++ = [self.palette getRgbColorAtIndex:bytes[0] >> 6];
                                *pixels++ = [self.palette getRgbColorAtIndex:(bytes[0] >> 4) & 0b11];
                                *pixels++ = [self.palette getRgbColorAtIndex:(bytes[0] >> 2) & 0b11];
                                *pixels++ = [self.palette getRgbColorAtIndex:bytes[0] & 0b11];
                                bytes++;
                            }
                        }
                    }
                }
            }
        }
        
        pixels = (UInt32 *)pixelData + lengthInBytes - 1 - w * 8;
        for (int r = lines - 8; r < lines; r++) {
            for (int c = 0; c < w; c++) {
                *pixels++ = [self.palette getRgbColorAtIndex:c / (w / 16)];
            }
        }
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
                    [self setBitsPerPlane:upf.bitsPerPlane];
                    self.bitsPerComponent = upf.bitsPerComponent;
                    self.dataOffset = (NSInteger)upf.pictureDataOffset;
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
                [Image writeCGImage:CGImageCreateWithImageInRect(imageRef, CGRectMake((self.mutableTexture.size.width - self.screenSize.width) / 2, (self.mutableTexture.size.height - self.screenSize.height) / 2, self.screenSize.width, self.screenSize.height)) to:savePanel.URL];
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

- (void)increaseWidth {
    _screenSize.width += self.bitsPerPlane;
    if (self.screenSize.width > self.mutableTexture.size.width) {
        _screenSize.width = self.mutableTexture.size.width;
    }
    [self modifyMutableTexture];
}

- (void)decreaseWidth {
    _screenSize.width -= self.bitsPerPlane;
    if (self.screenSize.width < self.bitsPerPlane) {
        _screenSize.width = self.bitsPerPlane;
    }
    [self modifyMutableTexture];
}

// MARK:- Public Getter & Setters

- (void)setBitsPerComponent:(NSUInteger)bitsPerComponent {
    _bitsPerComponent = bitsPerComponent > 1 ? bitsPerComponent : 1;
    [self modifyMutableTexture];
}

- (void)setBitsPerPlane:(NSUInteger)bitsPerPlane {
    _bitsPerPlane = bitsPerPlane > 7 ? bitsPerPlane & 0xF8 : 0; // Multiple of 8 & >= 8 only!
    [self modifyMutableTexture];
}

- (void)setPlaneCount:(NSUInteger)planeCount {
    _planeCount = planeCount > 0 ? planeCount : 1;
    [self.palette setColorCount:2 ^ self.planeCount];
    [self modifyMutableTexture];
}

- (void)setPixelArrangement:(PixelArrangement)pixelArrangement {
    _pixelArrangement = pixelArrangement;
    [self modifyMutableTexture];
}


- (void)setScreenSize:(CGSize)size {
    _screenSize = size;
    [self modifyMutableTexture];
}

- (void)setMaskInterleaved:(BOOL)maskInterleaved {
    _maskInterleaved = maskInterleaved;
}


// MARK:- Private Getter & Setters

- (void)setDataOffset:(NSInteger)dataOffset {
    if (_dataOffset + dataOffset < 0) {
        _dataOffset = 0;
    } else {
        _dataOffset = dataOffset + [self bytesPerLine] * (NSUInteger)self.screenSize.height < self.data.length ? dataOffset : self.data.length - [self bytesPerLine] * (NSUInteger)self.screenSize.height;
    }
}

- (void)setPaletteOffset:(NSInteger)paletteOffset {
    _paletteOffset = paletteOffset < self.data.length ? paletteOffset : paletteOffset -self.data.length;
}

// MARK:- Private Class Methods

- (NSUInteger)bytesPerLine {
    NSUInteger width = ( NSUInteger )self.screenSize.width;
    NSUInteger bytes;
    
    if (self.maskInterleaved == YES) {
        bytes = width / self.bitsPerPlane * ( self.bitsPerPlane / 8 * self.planeCount ) / 2;
        bytes += bytes / 4;
    } else {
        bytes = width / self.bitsPerPlane * ( self.bitsPerPlane / 8 * self.planeCount );
    }
    
    return bytes;
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
