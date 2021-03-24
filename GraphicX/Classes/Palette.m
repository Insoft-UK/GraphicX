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

#import "Palette.h"

@interface Palette()

// MARK: - Private Properties

@property NSData *data;

@end



@implementation Palette

// MARK: - Init

-(id)init {
    if ((self = [super init])) {
        [self setup];
    }
    
    return self;
}

-(void)setup {
    self.data = ( NSData* )[NSMutableData dataWithCapacity:1024];
    
    if (self.data != nil) {
        [self setColorCount:16];
        for ( int i = 0; i < self.colorCount; i++ ) {
            [self setRgbColor:0x111111 * i atIndex:i];
        }
    }
}

// MARK: - Public Instance Methods

-(void)loadWithContentsOfFile:( NSString* _Nonnull )file {
    NSData *actData = [NSData dataWithContentsOfFile:file];

    if ( actData.length >= 768 ) {
        UInt8* byte = ( UInt8* )actData.bytes;
        int c = 0;
        
        if ( actData.length >= 771 ) {
            [self setColorCount:( NSUInteger )byte[771]];
        } else {
            [self setColorCount:256];
        }
        
        for (; c < self.colorCount; c++) {
            [self setRgbColor:( ( UInt32 )byte[2] << 16 ) | ( ( UInt32 )byte[1] << 8 ) | ( UInt32 )byte[0] atIndex:c];
            byte += 3;
        }
    }
}

-(void)saveAsPhotoshopActAtPath:( NSString* _Nonnull )path {
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForWritingAtPath:path];
    
    if ( fileHandler != nil ) {
        NSData* actData = ( NSData* )[NSMutableData dataWithLength:772];
        if (actData != nil) {
            if (actData.length == 772) {
                UInt8* byte = ( UInt8* )actData.bytes;
                int c = 0;
                
                for (; c < self.colorCount; c++) {
                    UInt32 rgb = [self getRgbColorAtIndex:c];
                    *byte++ = rgb & 0xFF;
                    *byte++ = ( rgb & 0xFF00 ) >> 8;
                    *byte++ = ( rgb & 0xFF0000 ) >> 16;
                }
                
                // Zero... out any unused palette entries.
                for (; c < 256; c++) {
                    *byte++ = 0;
                    *byte++ = 0;
                    *byte++ = 0;
                }
                
                byte[1] = ( UInt8 )self.colorCount;
                byte[2] = 0xff;
                byte[3] = 0xff;
                
                
                [fileHandler writeData:actData];
            }
        }
        
        [fileHandler closeFile];
    }
}

-(UInt32)colorAtIndex:(NSUInteger)index {
    return *( UInt32* )( self.data.bytes + ( ( index & 255 ) << 2 ) );
}

// MARK: - Public Class Methods

// Atari ST  :- xx xx xx xx xx R2 R1 R0  xx G2 G1 G0 xx B2 B1 B0
+(UInt32)colorFrom9BitRgb:( UInt16 )rgb {
    UInt32 color;
#ifdef __LITTLE_ENDIAN__
    rgb = CFSwapInt16BigToHost(rgb);
#endif
    // xx C2 C1 C3 -> C2 C1 C0 [C2 | C1]
    rgb = ( ( rgb & 0x777 ) << 1 ) | ( ( rgb & 0x444 ) >> 2 ) | ( ( rgb & 0x222 ) >> 1 );
    color = ( ( UInt32 )( rgb & 0x0F00 ) >> 4 ) | ( ( UInt32 )( rgb & 0x00F0 ) << 8 ) | ( ( UInt32 )( rgb & 0x000F ) << 20 );
    return  color | ( color >> 4 ) | 0xFF000000;
}

// Atari STE :- xx xx xx xx R0 R3 R2 R1  G0 G3 G2 G1 B0 B3 B2 B1
+(UInt32)colorFrom12BitRgb:( UInt16 )rgb {
    UInt32 color;
#ifdef __LITTLE_ENDIAN__
    rgb = CFSwapInt16BigToHost(rgb);
#endif
    // C0 C3 C2 C1 -> C3 C2 C1 C0
    rgb = ( ( rgb & 0x777 ) << 1 ) | ( ( rgb & 0x888 ) >> 3 );
    color = ( ( UInt32 )( rgb & 0x0F00 ) >> 4 ) | ( ( UInt32 )( rgb & 0x00F0 ) << 8 ) | ( ( UInt32 )( rgb & 0x000F ) << 20 );
    return  color | ( color >> 4 ) | 0xFF000000;
}

+(BOOL)isAtariStFormat:( UInt16* _Nonnull )rgb {
    UInt16 color;
    
    for ( int i=0; i < 16; i++) {
        color = rgb[i];
#ifdef __LITTLE_ENDIAN__
        color = CFSwapInt16BigToHost(color);
#endif
        if ( color & 0b1111100010001000 ) return NO;
    }
    return ![self isAnyRepeatsInList:rgb withLength:16];
}

+(BOOL)isAtariSteFormat:( UInt16* _Nonnull )rgb {
    UInt16 color;

    for ( int i=0; i < 16; i++) {
        color = rgb[i];
#ifdef __LITTLE_ENDIAN__
        color = CFSwapInt16BigToHost(color);
#endif
        if ( color & 0b1111000000000000 ) return NO;
    }
    
    return ![self isAnyRepeatsInList:rgb withLength:16];
}

// MARK:- Public Getter & Setters

-(void)setColorCount:( NSUInteger )count {
    _colorCount = (count <= 256) ? count : 256;
}

-(void)setRgbColor:( UInt32 )rgb atIndex:(NSUInteger)index {
    *( UInt32* )( self.data.bytes + ( ( index & 255 ) << 2 ) ) = rgb | 0xFF000000;
}

-(UInt32)getRgbColorAtIndex:(NSUInteger)index {
    return *( UInt32* )( self.data.bytes + ( ( index & 255 ) << 2 ) );
}

// MARK:- Private Class Methods

+(BOOL)isAnyRepeatsInList:( UInt16* )list withLength:( NSUInteger )length {
    for (NSUInteger i = 0; i < length; i++) {
        for (NSUInteger j = 0; j < length; j++) {
            if (i != j) {
                if (list[i] == list[j]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
