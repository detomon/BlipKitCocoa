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

#import "BKCWaveform.h"

@implementation BKCWaveform

static id squareWaveform;
static id triangleWaveform;
static id noiseWaveform;
static id sawtoothWaveform;
static id sineWaveform;

@synthesize type;

+ (instancetype)squareWaveform
{
	if (squareWaveform == nil) {
		squareWaveform = [[self alloc] initWithType:BK_SQUARE];
	}

	return squareWaveform;
}

+ (instancetype)triangleWaveform
{
	if (triangleWaveform == nil) {
		triangleWaveform = [[self alloc] initWithType:BK_TRIANGLE];
	}

	return triangleWaveform;
}

+ (instancetype)noiseWaveform
{
	if (noiseWaveform == nil) {
		noiseWaveform = [[self alloc] initWithType:BK_NOISE];
	}

	return noiseWaveform;
}

+ (instancetype)sawtoothWaveform
{
	if (sawtoothWaveform == nil) {
		sawtoothWaveform = [[self alloc] initWithType:BK_SAWTOOTH];
	}

	return sawtoothWaveform;
}

+ (instancetype)sineWaveform
{
	if (sineWaveform == nil) {
		sineWaveform = [[self alloc] initWithType:BK_SINE];
	}
	
	return sineWaveform;
}

- (instancetype)init
{
	return [self initWithType:BK_SQUARE];
}

- (instancetype)initWithType:(BKEnum)theType
{
	BKInt res;

	if (self = [super initWithLength:0 numberOfComponents:1 valueSize:sizeof (BKFrame)]) {
		type = theType;
		res  = BKDataInit (& data);

		if (res < 0) {
			NSLog (@"*** Couldn't initialize BKData: %d", res);
			return nil;
		}
	}

	return self;
}

- (instancetype)initWithValues:(BKFrame const *)theValues length:(NSUInteger)theLength
{
	if (self = [self initWithType:BK_CUSTOM]) {
		if ([self setValues:theValues length:theLength] == NO) {
			return nil;
		}
	}

	return self;
}

- (instancetype)initWithData:(BKData const *)newData
{
	BKInt res;

	if (self = [super init]) {
		type = BK_CUSTOM;
		res  = BKDataInitCopy(& data, newData);

		if (res < 0) {
			NSLog (@"*** Couldn't initialize BKData: %d", res);
			return nil;
		}
	}

	return self;
}

- (void)dealloc
{
	BKDispose (& data);
}

- (BKFrame const *)phases
{
	return values;
}

- (BKData *)data
{
	return & data;
}

- (BOOL)updateData
{
	BKInt res;

	if (self.length < 2) {
		return NO;
	}

	res = BKDataSetFrames (& data, values, (BKInt)self.length, 1, YES);
	
	if (res < 0) {
		NSLog (@"*** Setting frames failed: %d", res);
		return NO;
	}

	return YES;
}

- (BOOL)setValues:(BKFrame const *)newValues length:(NSUInteger)newLength
{
	if (self.type != BK_CUSTOM) {
		NSLog (@"*** Can't set new phases: waveform is not a custom waveform");
		return NO;
	}

	if (newValues == NULL) {
		NSLog (@"*** Phases may not be NULL");
		return NO;
	}

	if (newLength < 2) {
		NSLog (@"*** Number of phases must be at least 2");
		return NO;
	}

	[self replaceValuesInRange:NSMakeRange (0, self.length) withValues:newValues length:newLength];

	return YES;
}

- (void)replaceValuesInRange:(NSRange)range withValues:(const void *)newValues length:(NSUInteger)length
{
	[super replaceValuesInRange:range withValues:newValues length:length];
	[self updateData];
}

@end
