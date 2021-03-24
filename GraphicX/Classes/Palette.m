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
        _color = ( UInt32* )self.data.bytes;
        _colorCount = 16;
        for ( int i = 0; i < self.colorCount; i++ ) {
            self.color[i] = 0xff000000 | (0x111111 * i);
        }
    }
}

-(void)loadWithContentsOfFile:( NSString* _Nonnull )file {
    NSData *actData = [NSData dataWithContentsOfFile:file];

    if ( actData.length >= 768 ) {
        UInt8* byte = ( UInt8* )actData.bytes;
        int c = 0;
        
        if ( actData.length >= 770 ) {
            _colorCount = ( NSUInteger )byte[1];
        } else {
            _colorCount = 256;
        }
        
        for (; c < _colorCount; c++) {
            self.color[c] = 0xFF000000 | ( ( UInt32 )byte[2] << 16 ) | ( ( UInt32 )byte[1] << 8 ) | ( UInt32 )byte[0];
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
                    *byte++ = self.color[c] & 0xFF;
                    *byte++ = ( self.color[c] & 0xFF00 ) >> 8;
                    *byte++ = ( self.color[c] & 0xFF0000 ) >> 16;
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

/* Compatible with Atari STE 12-Bit Palette
 * Atari ST  :- xx xx xx xx xx R2 R1 R0  xx G2 G1 G0 xx B2 B1 B0
 * Atari STE :- xx xx xx xx R0 R3 R2 R1  G0 G3 G2 G1 B0 B3 B2 B1
 */
+(UInt32)colorFrom9BitRgb:(UInt16)rgb {
    UInt32 color;

    rgb = ( ( rgb & 0x777 ) << 1 ) | ( ( rgb & 0x888 ) >> 3 );
    color = ( ( UInt32 )( rgb & 0x0F00 ) >> 4 ) | ( ( UInt32 )( rgb & 0x00F0 ) << 8 ) | ( ( UInt32 )( rgb & 0x000F ) << 20 );
    return  color | ( color >> 4 ) | 0xFF000000;
}

-(void)setColorCount:(NSUInteger)count {
    _colorCount = (count <= 256) ? count : 256;
}

@end
