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



#import <Cocoa/Cocoa.h>

#define MAX_DATA_BUFFER_SIZE    65536




UInt32 palette[256] = {
    0xff000000, 0xff111111, 0xff222222, 0xff333333, 0xff444444, 0xff555555, 0xff666666, 0xff777777,
    0xff888888, 0xff999999, 0xffaaaaaa, 0xffbbbbbb, 0xffcccccc, 0xffdddddd, 0xffeeeeee, 0xffffffff
};

@interface MainScene()

@property (nonatomic) SKMutableTexture *mutableTexture;
@property (nonatomic) NSData *data;
@property (nonatomic) NSInteger offset;
@property (nonatomic) NSInteger palOffset;

//@property NSInteger bytesPerLine;



@end

@implementation MainScene


- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    [self setup];
    
    Singleton.sharedInstance.mainScene = self;
}

- (void)willMoveFromView:(SKView *)view {
    
}

- (void)setup {
    _bytesPerBitplane = 2;
    _bitplanes = 4;
    self.offset = 0;
    self.palOffset = 0;
    self.bitsPerColor = 8;
    [self setScreenSize:CGSizeMake(320, 200)];
    _pixelArrangement = PixelArrangementPlanar;

    
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
    
    NSInteger width = (NSInteger)self.screenSize.width;
    NSInteger bytesPerLine = width * ( (self.bytesPerBitplane * 8) / (self.bitplanes * 2) );
    
    switch (theEvent.keyCode) {
            
        case 0x24 /* ENTER  */:
            [self adjustOffsetBy:width * bytesPerLine];
            break;
            

        case 0x33 /* BACKSPACE  */:
            [self adjustOffsetBy:-width * bytesPerLine];
            break;
            
        
        case 0x35 /* ESC */:
            self.offset = 0;
            self.palOffset = 0;
            break;
            
        case 0x7b /* CURSOR LEFT */:
            [self adjustOffsetBy:-1];
            break;
            
        case 0x7c /* CURSOR RIGHT */:
            [self adjustOffsetBy:1];
            break;
            
        case 0x7d /* CURSOR DOWN */:
            
            [self adjustOffsetBy:bytesPerLine];
            break;
            
        case 0x7e /* CURSOR UP */:
            [self adjustOffsetBy:-bytesPerLine];
            break;
            
            
        default:
            NSLog(@"keyDown:'%@' keyCode: 0x%02X", theEvent.characters, theEvent.keyCode);
            break;
    }
    
    NSLog(@"keyDown:'%@' keyCode: 0x%02X", theEvent.characters, theEvent.keyCode);
    
    [self updateMutableTexture];
    
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
    
    // Called before each frame is rendered
    
}

- (void)updateMutableTexture {
    if (self.data == nil) {
        [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
            UInt32 *pixels = (UInt32 *)pixelData;
            while (lengthInBytes -= 4) {
                *pixels = 0;
            }
        }];
        return;
    }
    
    NSInteger width = (NSInteger)self.screenSize.width;
    NSInteger height = (NSInteger)self.screenSize.height;
    NSInteger bytesPerLine = width * ( (self.bytesPerBitplane * 8) / (self.bitplanes * 2) );
    
    [self modifyTextureWithData: self.data rangeFrom:self.offset to: bytesPerLine * height + self.offset];
    
    
}

// Modify texure pixel data from raw data that is atari st bitmap graphics.
- (void)modifyTextureWithData:(const NSData *) data rangeFrom:(size_t)from to:(size_t)to {
    if (to < from) return;
    
    NSUInteger x = (to - from) / (int)self.screenSize.height * 2;
    
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        UInt32 *pixels = (UInt32 *)pixelData;
        UInt8 *bytes = (UInt8 *)data.bytes;
        
        bytes += from;
        
      
        int height = (int)self.screenSize.height;
        int width = (int)self.screenSize.width;
        
        int w = (int)self.mutableTexture.size.width;
        int lines = (int)self.mutableTexture.size.height;
        
        for (int r = -(lines - height) / 2; r < (height + (lines - height) / 2); ++r) {
            if (r < 0 || r >= height) {
                for (int c = 0; c < w; ++c) {
                    *pixels++ = palette[0];
                }
            } else {
                for (int c = -(w - width) / 2; c < (width + (w - width) / 2); ++c) {
                    if (c < 0 || c >= width) {
                        *pixels++ = palette[0];
                    }
                    else {
                        if (c < x) {
                            if (self.pixelArrangement == PixelArrangementPlanar) {
                                if (self.bytesPerBitplane == 1) {
                                    c+=7;
                                    UInt8 *planes = (UInt8 *)bytes;
                                    bytes += self.bytesPerBitplane * self.bitplanes;
                                    
                                    for (int n=7; n >= 0; n--) {
                                        int i = 0;
                                        for (int p=0; p<self.bitplanes; p++) {
                                            UInt8 plane = planes[p];
                                            if (plane & (1 << n)) {
                                                i |= (1 << p);
                                            }
                                        }
                                        *pixels++ = palette[i];
                                    }
                                } else {
                                    c+=15;
                                    UInt16 *planes = (UInt16 *)bytes;
                                    bytes += self.bytesPerBitplane * self.bitplanes;
                                    
                                    for (int n=15; n >= 0; n--) {
                                        int i = 0;
                                        for (int p=0; p<self.bitplanes; p++) {
                                            UInt16 plane = CFSwapInt16BigToHost(planes[p]);
                                            if (plane & (1 << n)) {
                                                i |= (1 << p);
                                            }
                                        }
                                        *pixels++ = palette[i];
                                    }
                                }
                            } else {
                                if (self.bitsPerColor == 8) {
                                    // Indexed Color
                                    *pixels++ = palette[*bytes++];
                                }
                                
                                if (self.bitsPerColor == 4) {
                                    // 16 Colors
                                    *pixels++ = palette[bytes[0] >> 4];
                                    *pixels++ = palette[bytes[0] & 0b1111];
                                    bytes++;
                                }
                                
                                if (self.bitsPerColor == 2) {
                                    // 4 Colors
                                    *pixels++ = palette[bytes[0] >> 6];
                                    *pixels++ = palette[(bytes[0] >> 4) & 0b11];
                                    *pixels++ = palette[(bytes[0] >> 2) & 0b11];
                                    *pixels++ = palette[bytes[0] & 0b11];
                                    bytes++;
                                }
                            }
                            
                        } else {
                            *pixels++ = palette[0];
                        }
                    }
                }
            }
        }
        
        pixels = (UInt32 *)pixelData;
        for (int r = 0; r < 16; r++) {
            for (int c = 0; c < w; c++) {
                *pixels++ = palette[c / (w / 16)];
            }
        }
    }];
    
    
}

// MARK: - Public Methods

- (void)nextPalette {
    [self findAtariSTPaletteFromData:self.data];
    [self updateMutableTexture];
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
                    self.bitplanes = upf.planes;
                    self.bytesPerBitplane = upf.bitsPerPlane / 8;
                    self.bitsPerColor = upf.colourBitCount;
                    self.offset = (NSInteger)upf.pictureDataOffset;
                    memcpy(palette, upf.palette, sizeof(palette));
                }
                [self updateMutableTexture];
            }
        }
    }
    
    
}

- (void)exportAs {
    NSURL *url;
    
    NSSavePanel *savePanel = [[NSSavePanel alloc] init];
    savePanel.title = @"GraphicX";
    savePanel.canCreateDirectories = YES;
    if (self.bitplanes > 1) {
        savePanel.nameFieldStringValue = @"result.bmp";
    } else {
        savePanel.nameFieldStringValue = @"result.pbm";
    }
    
    NSModalResponse modalResponse = [savePanel runModal];
    if (modalResponse == NSModalResponseOK) {
        url = savePanel.URL;
        if (url != nil) {
            NSInteger width = (NSInteger)self.screenSize.width;
            NSInteger bytesPerLine = width * ( (self.bytesPerBitplane * 8) / (self.bitplanes * 2) );
            
            if (self.bitplanes > 1) {
                saveAsBitmapImage([[[url absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""] cStringUsingEncoding:NSUTF8StringEncoding], self.data.bytes + self.offset, (int)bytesPerLine * 2, (int)self.screenSize.height, palette);
            } else {
                saveAsPortableBitmapImage([[[url absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""] cStringUsingEncoding:NSUTF8StringEncoding], self.data.bytes + self.offset, (int)bytesPerLine * 8, (int)self.screenSize.height);
            }
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
            saveAsPhotoshopPalette([[[url absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""] cStringUsingEncoding:NSUTF8StringEncoding], palette, 16, 0);
        }
    }
}

- (void)increaseWidth {
    _screenSize.width += self.bytesPerBitplane * 8;
    if (self.screenSize.width > self.mutableTexture.size.width) {
        _screenSize.width = self.mutableTexture.size.width;
    }
    [self adjustOffsetBy:0]; // Making sure the offset remains valid.
    [self updateMutableTexture];
}

- (void)decreaseWidth {
    _screenSize.width -= self.bytesPerBitplane * 8;
    if (self.screenSize.width < self.bytesPerBitplane * 8) {
        _screenSize.width = self.bytesPerBitplane * 8;
    }
    [self adjustOffsetBy:0]; // Making sure the offset remains a valid range.
    [self updateMutableTexture];
}

- (void)setBytesPerBitplane:(NSInteger)bytesPerBitplane {
    _bytesPerBitplane = bytesPerBitplane;
    [self adjustOffsetBy:0]; // Making sure the offset remains a valid range.
    [self updateMutableTexture];
}

- (void)setBitplanes:(NSInteger)bitplanes {
    _bitplanes = bitplanes;
    [self adjustOffsetBy:0]; // Making sure the offset remains a valid range.
    [self updateMutableTexture];
}

- (void)setPixelArrangement:(PixelArrangement)pixelArrangement {
    _pixelArrangement = pixelArrangement;
    [self adjustOffsetBy:0]; // Making sure the offset remains a valid range.
    [self updateMutableTexture];
}

- (void)setBitsPerColor:(NSInteger)bitsPerColor {
    _bitsPerColor = bitsPerColor;
    [self adjustOffsetBy:0]; // Making sure the offset remains a valid range.
    [self updateMutableTexture];
}

- (void)setScreenSize:(CGSize)size {
    _screenSize = size;
    [self adjustOffsetBy:0]; // Making sure the offset remains a valid range.
    [self updateMutableTexture];
}



//MARK:- Private Methods



-(BOOL)repeatedValues:(UInt16 *)list lengthOf:(NSUInteger)length {
    for (int i = 0; i < length; i++) {
        for (int j = 0; j < length; j++) {
            if (i != j) {
                if (list[i] == list[j]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(BOOL)isPosibleAnAtariSTPalette:(UInt16 *)list {
    for (int i = 0; i < 16; i++) {
        if (i == 0 && list[i] != 0) {
            return NO;
        }
        if (CFSwapInt16BigToHost(list[i]) & 0xf000) {
            return NO;
        }
    }
    return YES;
}

- (void)findAtariSTPaletteFromData:(const NSData *) data  {
    UInt8 *bytes = (UInt8 *)data.bytes;
    bytes += self.palOffset;
    NSUInteger lengthInBytes = data.length - 32 - self.palOffset;
    
    
    while (lengthInBytes--) {
        if ([self isPosibleAnAtariSTPalette:(UInt16 *)bytes] == YES) {
            if ([self repeatedValues:(UInt16 *)bytes lengthOf:16] == NO) {
                /// Palette found!
                for (int i=0; i<16; i++) {
                    /* Atari ST palettes
                     * xx xx xx xx xx R2 R1 R0  xx G2 G1 G0 xx B2 B1 B0
                     *
                     * Atari STE palettes
                     * xx xx xx xx R0 R3 R2 R1  G0 G3 G2 G1 B0 B3 B2 B1
                     *
                     */
                    
                    UInt32 r;
                    r = (UInt32)(((bytes[i * 2] << 1) & 0x0f) | (bytes[0] >> 3));
                    r |= r << 4;
                    
                    UInt32 g;
                    g = (UInt32)(((bytes[i * 2 + 1] << 1) & 0xf0) | ((bytes[i * 2 + 1] & 0xf0) >> 3));
                    g |= g >> 4;
                    
                    UInt32 b;
                    b = (UInt32)(((bytes[i * 2 + 1] << 1) & 0x0f) | ((bytes[i * 2 + 1] & 0x0f) >> 3));
                    b |= b << 4;
                    
                    NSLog(@"RGB: 0x%02X 0x%02X 0x%02X", r,g,b);
                    
                
                    palette[i] = 0xff000000 | r | g << 8 | b << 16;
                }
                
                self.palOffset++;
                
                if (self.palOffset + 32 >= data.length) {
                    self.palOffset = 0;
                }
                
                return;
            }
        }
        
        self.palOffset++;
        bytes++;
    }
    
    
    if (self.palOffset + 32 >= data.length) {
        self.palOffset = 0;
    }
    
}




- (void)adjustOffsetBy:(NSInteger)value {
    if (self.data != nil) {
        if (value != 0) {
            self.offset += value;
            
            if ( self.offset < 0 ) {
                self.offset = 0;
            }
        }
        
        // Check offset is valid and will not result in memory being accessed beyond the memory allocated.
        NSInteger width = (NSInteger)self.screenSize.width;
        NSInteger height = (NSInteger)self.screenSize.height;
        NSInteger bytesPerLine = width / ( (self.bytesPerBitplane * 8) / (self.bitplanes * 2) );
        
        if ( bytesPerLine * height + self.offset >= self.data.length ) {
            self.offset = self.data.length - bytesPerLine * height;
        }
    } else {
        self.offset = 0;
    }
    
    [self updateMutableTexture];
}





@end
