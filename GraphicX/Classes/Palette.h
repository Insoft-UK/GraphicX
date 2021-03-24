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

#ifndef Palette_h
#define Palette_h

@interface Palette: NSObject

// MARK: - Properties

@property (readonly) NSUInteger colorCount;

// MARK: - Instance Methods

-(void)loadWithContentsOfFile:( NSString* _Nonnull )file;
-(void)saveAsPhotoshopActAtPath:( NSString* _Nonnull )path;
-(UInt32)colorAtIndex:(NSUInteger)index;

// MARK: - Class Methods

+(UInt32)colorFrom9BitRgb:( UInt16 )rgb;
+(UInt32)colorFrom12BitRgb:( UInt16 )rgb;

+(BOOL)isAtariStFormat:( UInt16* _Nonnull )rgb;
+(BOOL)isAtariSteFormat:( UInt16* _Nonnull )rgb;

// MARK:- Getter & Setters

-(void)setColorCount:(NSUInteger)count;
-(void)setRgbColor:( UInt32 )rgb atIndex:(NSUInteger)index;
-(UInt32)getRgbColorAtIndex:(NSUInteger)index;

@end


#endif /* Palette_h */
