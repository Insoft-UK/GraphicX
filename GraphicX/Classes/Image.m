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
#import "GraphicX-Swift.h"

@interface Image()

// MARK: - Private Properties

@property SKMutableTexture *mutableTexture;
@property NSMutableData *mutableData;

@property NSInteger offset;
@property BOOL changes;

@property NSInteger paletteOffset;

@end

@implementation Image


// MARK: - Init

- (id)initWithSize:(CGSize)size {
    if ((self = [super init])) {
        _size = CGSizeMake(256, 256);
        [self setupWithSize: size];
        self.changes = YES;
    }
    
    return self;
}

- (void)setupWithSize:(CGSize)size {
    self.mutableTexture = [[SKMutableTexture alloc] initWithSize:size];
    self.mutableData = [[NSMutableData alloc] initWithCapacity:(NSUInteger)2^32];
    self.mutableData.length = self.size.width * self.size.height * sizeof(UInt32);
    
    _data = (NSData*)self.mutableData;
    
    SKSpriteNode *node;
    
    SKMutableTexture *texture = [[SKMutableTexture alloc] initWithSize:size];
    if (texture != nil) {
        [texture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
            UInt32 *pixel = pixelData;
            
            NSUInteger s = size.width;
            NSUInteger l = size.height;
            
            for (NSUInteger r = 0; r < l; ++r) {
                for (NSUInteger c = 0; c < s; ++c) {
                    pixel[r * s + c] = (r & 0b1000 ? c+8 : c) & 0b1000 ? 0xFFFF0000 : 0xFFAA0000;
                }
            }
        }];
        
        node = [SKSpriteNode spriteNodeWithTexture:(SKTexture*)texture size:size];
        node.texture.filteringMode = SKTextureFilteringNearest;
        [self addChild:node];
        
        _palette = [[Palette alloc] init];
    }
    
    if (self.mutableTexture) {
        node = [SKSpriteNode spriteNodeWithTexture:(SKTexture*)self.mutableTexture size:size];
        node.yScale = -1;
        node.texture.filteringMode = SKTextureFilteringNearest;
        [self addChild:node];
    }
    
    self.planeCount = 4;
    self.alphaPlane = NO;
    self.bitsPerPixel = 16;
}

// MARK: - Public Instance Methods

- (void)firstAtariSTPalette {
    self.paletteOffset = 0;
    [self nextAtariSTPalette];
}
- (void)nextAtariSTPalette {
    const UInt8 *bytes = (const UInt8 *)self.mutableData.bytes + self.paletteOffset;
    NSInteger limit = self.mutableData.length - sizeof(UInt16) * 16;

    while (self.paletteOffset <= limit) {
        const UInt16* pal = ( const UInt16* )bytes;
        if ([Palette isAtariSteFormat:( const UInt16* )bytes] == YES) {
            for (int i=0; i<16; i++) {
                [self.palette setRgbColor:[Palette colorFrom12BitRgb:pal[i]] atIndex:i];
            }
            [self.palette setColorCount:16];
            [self.palette setTransparentIndex:0];
            return;
        } else if ([Palette isAtariStFormat:( const UInt16* )bytes] == YES) {
            for (int i=0; i<16; i++) {
                [self.palette  setRgbColor:[Palette colorFrom9BitRgb:pal[i]] atIndex:i];
            }
            [self.palette setColorCount:16];
            [self.palette setTransparentIndex:0];
            return;
        }
        self.paletteOffset++;
        bytes++;
    }
    
    self.changes = YES;
}

-(void)modifyWithContentsOfURL:(NSURL*)url {
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.mutableData.length = data.length;
    [self.mutableData setData:data];
    
    self.changes = YES;
}

-(void)nextDataBlock {
    [self setDataOffsetBy:[self bytesPerLine] * (NSInteger)self.size.height];
}

-(void)previousDataBlock {
    [self setDataOffsetBy:-[self bytesPerLine] * (NSInteger)self.size.height];
}

-(void)decreaseBySingleLine {
    [self setDataOffsetBy:-[self bytesPerLine]];
}

-(void)increaseBySingleLine {
    [self setDataOffsetBy:[self bytesPerLine]];
}

-(void)decreaseByBytes:(NSUInteger)bytes {
    [self setDataOffsetBy:-(NSInteger)bytes];
}

-(void)increaseByBytes:(NSUInteger)bytes {
    [self setDataOffsetBy:(NSInteger)bytes];
}

-(void)setDataOffsetBy:(NSInteger)amount {
    self.offset += amount;
    
    if (self.offset < 0) {
        self.offset = 0;
        return;
    }
    
    if (self.offset > self.mutableData.length - (NSInteger)self.size.height * [self bytesPerLine]) {
        self.offset = (NSInteger)(self.mutableData.length - (NSInteger)self.size.height * [self bytesPerLine]);
    }
    
    self.changes = YES;
}

-(void)setDataOffsetTo:(NSInteger)amount {
    [self setDataOffsetBy:amount - self.offset];
}

-(void)home {
    self.offset = 0;
    self.changes = YES;
}

-(void)end {
    self.offset = self.offset = (NSInteger)(self.mutableData.length - (NSInteger)self.size.height * [self bytesPerLine]);
    self.changes = YES;
}

-(void)saveImageAtURL:(NSURL *)url {
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        CGImageRef imageRef = [Image createCGImage:self.mutableTexture.size ofPixelData:pixelData];
        [Ximage writeCGImage:CGImageCreateWithImageInRect(imageRef, CGRectMake((self.mutableTexture.size.width - self.size.width) / 2, (self.mutableTexture.size.height - self.size.height) / 2, self.size.width, self.size.height)) to:url];
        CGImageRelease(imageRef);
    }];
}

-(void)updateWithDelta:(NSTimeInterval)delta {
    if ([self.palette updateWithDelta:delta] == YES) {
        self.changes = YES;
    }
    
    if (self.changes == NO) return;
    
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        UInt32 *pixel = pixelData;
        const UInt8 *bytes = self.mutableData.bytes + self.offset;
        
        NSUInteger s = self.mutableTexture.size.width;
        NSUInteger l = self.mutableTexture.size.height;
        
        NSUInteger w = self.size.width;
        NSUInteger h = self.size.height;
        
        for (NSUInteger r = (l - h) / 2; r < l - (l - h) / 2; ++r) {
            for (NSUInteger c = (s - w) / 2; c < s - (s - w) / 2; ++c) {
                if ([self isPlaner] == YES) {
                    // Planer
                    if (self.bitsPerPixel == 8) {
                        UInt8 *planeData = (UInt8 *)bytes;
                        if (self.alphaPlane == YES) {
                            for (int n=(int)self.bitsPerPixel - 1; n >= 0; n--) {
                                UInt8 plane = *planeData;

                                if (plane & (1 << n)) {
                                    pixel[r * s + c + self.bitsPerPixel - 1 - n] = 0;
                                } else {
                                    pixel[r * s + c + self.bitsPerPixel - 1 - n] = 0xFF000000;
                                }
                            }
                            bytes += 1;
                        }
                        for (int n=7; n >= 0; n--) {
                            int i = 0;
                            for (int p=0; p<(int)self.planeCount; p++) {
                                UInt8 plane = planeData[p];
                                if (plane & (1 << n)) {
                                    i |= (1 << p);
                                }
                            }
                            
                            pixel[r * s + c + self.bitsPerPixel - 1 - n] = (int)self.planeCount > 1 ? [self.palette rgbColorAtIndex:i] : (0xFFFFFF * i) | 0xFF000000;
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
                                    pixel[r * s + c + self.bitsPerPixel - 1 - n] = 0;
                                } else {
                                    pixel[r * s + c + self.bitsPerPixel - 1 - n] = 0xFF000000;
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
                            UInt32 color = [self.palette rgbColorAtIndex:colorIndex];
                            if (self.alphaPlane == YES && colorIndex == 0) {
                                color &= 0x00FFFFFF;
                            }
                            pixel[r * s + c + self.bitsPerPixel - 1 - n] = self.planeCount > 1 ? color : (0xFFFFFF * colorIndex) | 0xFF000000;
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
                                pixel[r * s + c] = trueColor;
                            }
                            bytes += 3;
                            break;
                            
                        case 8: // 8 Bits Indexed Color...
                            pixel[r * s + c] = [self.palette rgbColorAtIndex:bytes[0]];
                            if (self.palette.transparentIndex == bytes[0] && self.alphaPlane == YES) {
                                pixel[r * s + c] = 0;
                            }
                            bytes += 1;
                            break;
                            
                        case 4: // 4 Bits Indexed Color...
                            pixel[r * s + c] = [self.palette rgbColorAtIndex:bytes[0] >> 4];
                            pixel[r * s + c + 1] = [self.palette rgbColorAtIndex:bytes[0] & 0b1111];
                            bytes += 1;
                            c += 1;
                            break;
                    
                        case 2: // 2 Bits Indexed Color...
                            pixel[r * s + c] = [self.palette rgbColorAtIndex:bytes[0] >> 6];
                            pixel[r * s + c + 1] = [self.palette rgbColorAtIndex:(bytes[0] >> 4) & 0b11];
                            pixel[r * s + c + 2] = [self.palette rgbColorAtIndex:(bytes[0] >> 2) & 0b11];
                            pixel[r * s + c + 3] = [self.palette rgbColorAtIndex:bytes[0] & 0b11];
                            bytes += 1;
                            c += 3;
                            break;
                            
                        case 1:
                            for (int n=0; n<8; n++) {
                                if (*bytes & (1 << n)) {
                                    pixel[r * s + c + n] = 0xFFFFFFFF;
                                } else {
                                    pixel[r * s + c + n] = 0xFF000000;
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
    }];
    
    self.changes = NO;
}

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

+ (BOOL)writeCGImage:(CGImageRef)image to:(NSURL *)destinationURL __attribute__((warn_unused_result)) {
    if (image == nil) {
        return NO;
    }
    CFURLRef cfurl = (__bridge CFURLRef)destinationURL;
    
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL(cfurl, kUTTypePNG, 1, nil);
    CGImageDestinationAddImage(destinationRef, image, nil);
    return CGImageDestinationFinalize(destinationRef);
}

// MARK:- Public Getter & Setters

- (void)setBitsPerPixel:(UInt32)bitsPerPixel {
    _bitsPerPixel = bitsPerPixel > 0 ? bitsPerPixel : 1;
    if (self.planeCount > 1) {
        _bitsPerPixel = _bitsPerPixel > 7 ? _bitsPerPixel & 0xF8 : 8;
    }
    
    self.changes = YES;
}

- (void)setPlaneCount:(UInt32)planeCount {
    _planeCount = planeCount % 5;
    if (planeCount <= 1) {
        self.alphaPlane = NO;
    }
    
    self.changes = YES;
}

- (void)setAlphaPlane:(BOOL)state {
    _alphaPlane = state;
    self.changes = YES;
}

- (void)setSize:(CGSize)size {
    NSInteger bytesPerLine = ( NSInteger )(size.width * (CGFloat)self.bitsPerPixel / 8.0 / (CGFloat)self.planeCount);
    if (bytesPerLine * (NSInteger)size.height > self.mutableData.length) {
        size.width = 16;
        size.height = 16;
    }
    
    if (size.width < self.size.width || size.height < self.size.height) {
        // When size is reduced then image pixel data must be zeroed out!
        [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
            memset(pixelData, 0, lengthInBytes);
        }];
    }
    
    _size = size;
    
    if (self.size.width < self.bitsPerPixel) {
        _size.width = self.bitsPerPixel;
    }
    if (self.size.width > self.mutableTexture.size.width) {
        _size.width = self.mutableTexture.size.width;
    }
    if (self.size.height < 8.0) {
        _size.height = 8.0;
    }
    if (self.size.height > self.mutableTexture.size.height) {
        _size.height = self.mutableTexture.size.height;
    }
    
    self.changes = YES;
}

// MARK:- Private Class Methods

-(BOOL)isPlaner {
    return self.planeCount > 1 ? YES : NO;
}

-(BOOL)isPacked {
    return self.planeCount <= 1 ? YES : NO;
}

-(NSInteger)bytesPerLine {
    return ( NSInteger )(self.size.width * (CGFloat)self.bitsPerPixel / 8.0 / (CGFloat)self.planeCount);
}



@end


