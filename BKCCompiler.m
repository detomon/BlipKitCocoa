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
#import "BKTKContext.h"
#import "BKCInstrument.h"

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

static BKInt putToken (BKTKToken const * token, BKCCompiler * self)
{
	BKInt res;

	if ((res = BKTKParserPutTokens (& self -> parser, token, 1)) != 0) {
		return res;
	}

	return 0;
}

- (BOOL)compileBytes:(void const *)bytes size:(NSUInteger)size error:(NSError **)error
{
	BKInt res = 0;
	BKTKParserNode * nodeTree;
	NSMutableString * errorMsg = [[NSMutableString alloc] init];

	[self reset];
	*error = nil;

	res = BKTKTokenizerPutChars (& tokenizer, bytes, size, (BKTKPutTokenFunc) putToken, (__bridge void *) self);

	// terminate parser
	if (res == 0) {
		res = BKTKTokenizerPutChars (& tokenizer, (void const *) "", 0, (BKTKPutTokenFunc) putToken, (__bridge void *) self);
	}

	if (BKTKParserHasError (& parser)) {
		[errorMsg appendFormat:@"%s\n", parser.buffer];
	}
	else if (BKTKTokenizerHasError (& tokenizer)) {
		[errorMsg appendFormat:@"%s\n", tokenizer.buffer];
	}

	if (BKTKTokenizerHasError (& tokenizer) || BKTKParserHasError (& parser)) {
		*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:res userInfo:@{
			NSLocalizedDescriptionKey: errorMsg
		}];

		return NO;
	}

	nodeTree = BKTKParserGetNodeTree (&parser);

	if ((res = BKTKCompilerCompile (&compiler, nodeTree)) != 0) {
		[errorMsg appendFormat:@"%s\n", compiler.error.str];

		*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:res userInfo:@{
			NSLocalizedDescriptionKey: errorMsg
		}];

		return NO;
	}

	return YES;
}

- (BKInstrument *)instrumentByName:(NSString *)name
{
	BKTKInstrument* instrument = NULL;

	BKHashTableLookup(&compiler.instruments, name.UTF8String, (void **) &instrument);

	return instrument ? &instrument->instr : NULL;
}

- (BKData *)waveformByName:(NSString *)name
{
	BKTKWaveform* waveform = NULL;

	BKHashTableLookup(&compiler.waveforms, name.UTF8String, (void **) &waveform);

	return waveform ? &waveform->data : NULL;
}

- (BKData *)sampleByName:(NSString *)name
{
	BKTKSample* sample = NULL;

	BKHashTableLookup(&compiler.samples, name.UTF8String, (void**) &sample);

	return sample ? &sample->data : NULL;
}

- (NSDictionary *)namedInstruments
{
	BKHashTableIterator itor;
	char const * key;
	BKTKInstrument * instr;
	NSMutableDictionary * instruments = [[NSMutableDictionary alloc] initWithCapacity:BKHashTableSize (&compiler.instruments)];

	BKHashTableIteratorInit (&itor, &compiler.instruments);

	while (BKHashTableIteratorNext (&itor, &key, (void **) &instr)) {
		BKCInstrument * instrument = [[BKCInstrument alloc] initWithInstrument: &instr -> instr];

		[instruments setValue:instrument forKey:[NSString stringWithUTF8String:key]];
	}

	return instruments;
}

- (void)reset
{
	BKTKCompilerReset (& compiler);
	BKTKParserReset (& parser);
	BKTKTokenizerReset (& tokenizer);
}

@end
