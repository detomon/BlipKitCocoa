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
		if (BKTKTokenizerInit (& tokenizer) != 0) {
			return nil;
		}

		if (BKTKParserInit (& parser) != 0) {
			return nil;
		}

		if (BKTKCompilerInit (& compiler) != 0) {
			return nil;
		}
	}

	return self;
}

- (void)dealloc
{
	BKDispose (& tokenizer);
	BKDispose (& parser);
	BKDispose (& compiler);
}

- (BKTKTokenizer *)tokenizer
{
	return & tokenizer;
}

- (BKTKParser *)parser
{
	return & parser;
}

- (BKTKCompiler *)compiler
{
	return & compiler;
}

- (BOOL)compileString:(NSString *)string error:(NSError **)error
{
	return [self compileData:[string dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

- (BOOL)compileData:(NSData *)data error:(NSError **)error
{
	return [self compileBytes:data.bytes size:data.length error:error];
}

static BKInt putTokens (BKTKToken const * tokens, BKUSize count, BKCCompiler * self)
{
	BKInt res;

	if ((res = BKTKParserPutTokens (& self -> parser, tokens, count)) != 0) {
		return res;
	}

	return 0;
}

- (BOOL)compileBytes:(void const *)bytes size:(NSUInteger)size error:(NSError **)error
{
	BKInt res = 0;
	NSMutableString * errorMsg;

	[self reset];
	*error = nil;

	BKTKTokenizerPutChars (& tokenizer, bytes, size, (BKTKPutTokenFunc) putTokens, (__bridge void *) self);

	if (BKTKTokenizerHasError (& tokenizer)) {
		if (!errorMsg) {
			errorMsg = [[NSMutableString alloc] init];
		}

		[errorMsg appendFormat:@"%s", tokenizer.buffer];
	}

	if (BKTKParserHasError (& parser)) {
		if (!errorMsg) {
			errorMsg = [[NSMutableString alloc] init];
		}

		[errorMsg appendFormat:@"%s", parser.buffer];
	}

	if (BKTKTokenizerHasError (& tokenizer) || BKTKParserHasError (& parser)) {
		*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:res userInfo:@{
			NSLocalizedDescriptionKey: errorMsg
		}];

		return NO;
	}

	return YES;
}

- (void)reset
{
	BKTKCompilerReset (& compiler);
	BKTKParserReset (& parser);
	BKTKTokenizerReset (& tokenizer);
}

@end
