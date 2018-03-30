/**
 * Copyright (c) 2014 Simon Schoenenberger
 * http://blipkit.monoxid.net/
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "BlipKit.h"
#import "BKTKCompiler.h"
#import "BKTKParser.h"
#import "BKTKTokenizer.h"

@interface BKCCompiler : NSObject
{
	BKTKCompiler  compiler;
	BKTKTokenizer tokenizer;
	BKTKParser    parser;
}

/**
 * The underlaying tokenizer object
 */
@property (readonly) BKTKTokenizer * tokenizer;

/**
 * The underlaying parser object
 */
@property (readonly) BKTKParser * parser;

/**
 * The underlaying compiler object
 */
@property (readonly) BKTKCompiler * compiler;

/**
 * Compile string
 */
- (BOOL)compileString:(NSString *)string error:(NSError **)error;

/**
 * Compile data
 */
- (BOOL)compileData:(NSData *)data error:(NSError **)error;

/**
 * Compile bytes
 */
- (BOOL)compileBytes:(void const *)bytes size:(NSUInteger)size error:(NSError **)error;

/**
 * Get instrument by name
 */
- (BKInstrument *)instrumentByName:(NSString *)name;

/**
 * Get waveform by name
 */
- (BKData *)waveformByName:(NSString *)name;

/**
 * Get waveform by name
 */
- (BKData *)sampleByName:(NSString *)name;

@end
