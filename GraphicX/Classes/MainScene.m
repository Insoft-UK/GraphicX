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
    UniversalPictureFormat upf = getUniversalPictureFormat(self.image.data.bytes, self.image.data.length);
    if (upf.imageDataOffset != 0) {
        [self.image setPlaneCount:upf.planeCount];
        [self.image setBitsPerPixel:upf.bitsPerPixel];
        [self.image setSize:CGSizeMake(upf.width, upf.height)];
        [self.image increaseByBytes:upf.imageDataOffset];
        [self.image.palette setAnimationLowerLimit:upf.colorLowerLimit withUpperLimitOf:upf.colorUpperLimit withStep:upf.numOfColorSteps durationOf:upf.animSpeed];
        for (int i=0; i<256; i++) {
            [self.image.palette setRgbColor:upf.palette[i] atIndex:i];
        }
        [self.image.palette setColorCount:upf.numOfColors];
        if (*upf.title != 0) {
            self.view.window.title = [NSString stringWithCString:upf.title encoding:NSUTF8StringEncoding];
        }
    }
}


// MARK:- Public Getter & Setters


// MARK:- Private Getter & Setters


// MARK:- Private Class Methods


@end
