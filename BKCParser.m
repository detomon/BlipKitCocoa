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

#import "BKCParser.h"

@implementation BKCParser

- (instancetype)init
{
	if ((self = [super init])) {
		if (BKSTParserInit (& parser, NULL, 0) != 0) {
			return nil;
		}
	}
	
	return self;
}

- (void)dealloc
{
	BKDispose (& parser);
}

- (BKSTParser *)parser
{
	return & parser;
}

- (void)enumerateCommandsInString:(NSString *)string block:(void (^) (BKSTCmd * cmd, BOOL * stop))block
{
	[self enumerateCommandsInData:[string dataUsingEncoding:NSUTF8StringEncoding] block:block];
}

- (void)enumerateCommandsInData:(NSData *)data block:(void (^) (BKSTCmd * cmd, BOOL * stop))block
{
	[self enumerateCommandsInBytes:data.bytes size:data.length block:block];
}

- (void)enumerateCommandsInBytes:(void const *)bytes size:(NSUInteger)size block:(void (^) (BKSTCmd * cmd, BOOL * stop))block
{
	BKSTParserSetData (& parser, bytes, size);
	[self parseAllCommandWithBlock:block];
}

- (void)parseAllCommandWithBlock:(void (^) (BKSTCmd * block, BOOL * stop))block
{
	BOOL stop;
	BKSTCmd cmd;

	while (BKSTParserNextCommand (& parser, & cmd)) {
		stop = NO;
		block (& cmd, & stop);
		
		if (stop) {
			break;
		}
	}
}

@end
