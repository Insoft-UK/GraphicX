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

@interface MainScene()

@property SKLabelNode *info;
@property NSTimeInterval lastUpdateTime;
@property Image *image;

@end

@implementation MainScene

// MARK: - View

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    [self setup];
    
    Singleton.sharedInstance.mainScene = self;
    Singleton.sharedInstance.image = self.image;
}

- (void)willMoveFromView:(SKView *)view {
    
}

// MARK: - Setup

- (void)setup {
    CGSize size = NSApp.windows.firstObject.frame.size;
    self.size = CGSizeMake(size.width, size.height - 28);
    
    self.image = [[Image alloc] initWithSize:self.size];
    self.image.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    [self addChild:self.image];
    
    self.info = [SKLabelNode labelNodeWithText:@"info..."];
    self.info.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.info.position = CGPointMake(self.size.width - 8, 8);
    self.info.fontSize = 10;
    self.info.fontName = @"Arial Bold";
    [self addChild:self.info];
    

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

    NSUInteger flags = [theEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
    if( flags == NSEventModifierFlagCommand ){
        switch (theEvent.keyCode) {
            case 0x0D: // W
                //[self.image home];
                [self.image setDataOffsetTo:0];
                break;
                
            case 0x01: // S
                //[self.image end];
                [self.image setDataOffsetTo:self.image.data.length];
                break;
        }
    } else {
        switch (theEvent.keyCode) {
            case 0x02: // D
                [self.image setDataOffsetBy:self.image.bitsPerPixel * self.image.planeCount / 8];
                break;
                
            case 0x00: // A
                [self.image setDataOffsetBy:-(self.image.bitsPerPixel * self.image.planeCount / 8)];
                break;
                
            case 0x0D: // W
                {
                    for (NSInteger n=0; n<8; n++) {
                        [self.image decreaseBySingleLine];
                    }
                }
                break;
                
            case 0x01: // S
                {
                    for (NSInteger n=0; n<8; n++) {
                        [self.image increaseBySingleLine];
                    }
                }
                break;
                
            case 0x24 /* ENTER  */:
                [self.image nextDataBlock];
                break;
                
                
            case 0x33 /* BACKSPACE  */:
                [self.image previousDataBlock];
                break;
                
                
            case 0x35 /* ESC */:
                break;
                
            case 0x7b /* CURSOR LEFT */:
                [self.image setDataOffsetBy:-1];
                break;
                
            case 0x7c /* CURSOR RIGHT */:
                [self.image setDataOffsetBy:1];
                break;
                
            case 0x7d /* CURSOR DOWN */:
                [self.image increaseBySingleLine];
                break;
                
            case 0x7e /* CURSOR UP */:
                [self.image decreaseBySingleLine];
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
    NSTimeInterval delta = currentTime - self.lastUpdateTime;
    self.lastUpdateTime = currentTime;
    
    [self.image updateWithDelta:delta];
    self.info.text = [NSString stringWithFormat:@"%d x %d",(int)self.image.size.width, (int)self.image.size.height];
}


// MARK: - Class Public Methods

-(void)checkForKnownFormats {
    
    if (isNEOchromeFormat(self.image.data.bytes, self.image.data.length) == true) {
        NEOchrome *neo = (NEOchrome *)self.image.data.bytes;
        
        // Palette
        for (NSInteger i=0; i<256; i++) {
            UInt32 color = [Palette colorFrom12BitRgb:neo->palette[i]];
            [self.image.palette setRgbColor:color atIndex:i];
        }
        [self.image.palette setColorCount:16];
        [self.image.palette setTransparentIndex:256];
        
        if (CFSwapInt16BigToHost(neo->colorAniLimits) & 0x8000) { /// Palette Animation!
            [self.image.palette setColorAnimationWith:(CFSwapInt16BigToHost(neo->colorAniLimits) >> 4) & 0xF
                                           rightLimit:CFSwapInt16BigToHost(neo->colorAniLimits) & 0xF
                                             withStep:CFSwapInt16BigToHost(neo->colorAniSpeedDir) & 0xFF
                                           cycleSpeed:(NSTimeInterval)(CFSwapInt16BigToHost(neo->colorAniSpeedDir) & 0xFF)];
        }
        
        // Image
        [self.image setPlaneCount:4];
        [self.image setBitsPerPixel:16];
        [self.image setSize:CGSizeMake(320, 200)];
        [self.image setDataOffsetTo:sizeof(NEOchrome)];
        return;
    }
    
    if (isDegasFormat(self.image.data.bytes, self.image.data.length) == true) {
        Degas *degas = (Degas *)self.image.data.bytes;
        
        // Palette
        for (NSInteger i=0; i<256; i++) {
            UInt32 color = [Palette colorFrom12BitRgb:degas->palette[i]];
            [self.image.palette setRgbColor:color atIndex:i];
        }
        [self.image.palette setColorCount:16];
        [self.image.palette setTransparentIndex:256];
        
        // Image
        switch (CFSwapInt16BigToHost(degas->resolution) & 3) {
            case 0:
                [self.image setPlaneCount:4];
                [self.image setBitsPerPixel:16];
                [self.image setSize:CGSizeMake(320, 200)];
                break;
                
            case 1:
                [self.image setPlaneCount:2];
                [self.image setBitsPerPixel:16];
                [self.image setSize:CGSizeMake(640, 200)];
                break;
                
            case 2:
                [self.image setPlaneCount:1];
                [self.image setBitsPerPixel:1];
                [self.image setSize:CGSizeMake(640, 400)];
                break;
                
            default:
                break;
        }
        
        [self.image setDataOffsetTo:sizeof(Degas)];
        return;
    }
}


// MARK:- Public Getter & Setters


// MARK:- Private Getter & Setters


// MARK:- Private Class Methods


@end
