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

#import "BKCCompiler.h"

@implementation BKCCompiler

- (instancetype)init
{
	if ((self = [super init])) {
		if (BKCompilerInit (& compiler) != 0) {
			return nil;
		}

		parser = [[BKCParser alloc] init];
	}

	return self;
}

- (void)dealloc
{
	BKDispose (& compiler);
}

- (BKCompiler *)compiler
{
	return & compiler;
}

- (void)compileString:(NSString *)string
{
	[self compileData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)compileData:(NSData *)data
{
	[self compileBytes:data.bytes size:data.length];
}

- (void)compileBytes:(void const *)bytes size:(NSUInteger)size
{
	BKCompilerReset (& compiler, YES);

	if (BKCompilerCompile (& compiler, parser.parser, 0) != 0) {
		
	}
}

@end