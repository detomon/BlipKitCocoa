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

#import "BKCContext.h"

#define DEFAULT_NUM_CHANNELS 2
#define DEFAULT_SAMPLE_RATE 44100

@implementation BKCContext

@synthesize audioUnit;
@synthesize unitLock;

- (instancetype)init
{
	return [self initWithNumberOfChannels:DEFAULT_NUM_CHANNELS sampleRate:DEFAULT_SAMPLE_RATE];
}

- (instancetype)initWithNumberOfChannels:(UInt32)numberOfChannels sampleRate:(UInt32)sampleRate
{
	BKInt res;

	if ((self = [super init])) {
		res = BKContextInit (& context, numberOfChannels, sampleRate);

		if (res < 0) {
			NSLog (@"*** Couldn't initialize BKContext: %d", res);
			return nil;
		}

		tracks   = [[NSMutableArray alloc] init];
		dividers = [[NSMutableArray alloc] init];
		unitLock = [[NSRecursiveLock alloc] init];
	}

	return self;
}

- (void)dealloc
{
	BKDispose (& context);
}

- (BKContext *)context
{
	return & context;
}

- (NSArray *)tracks
{
	return tracks;
}

- (UInt32)sampleRate
{
	return context.sampleRate;
}

- (UInt32)numberOfChannels
{
	return context.numChannels;
}

- (BOOL)start
{
	return [self.audioUnit start];
}

- (BOOL)stop
{
	return [self.audioUnit stop];
}

- (void)reset
{
	BKContextReset (& context);
}

- (BOOL)setAttribute:(BKCAttr)attribute value:(BKInt)value
{
	BKInt res;

	[self lock];
	res = BKSetAttr (& context, attribute, value);
	[self unlock];

	return res >= 0;
}

- (BOOL)getAttribute:(BKCAttr)attribute value:(BKInt *)value
{
	BKInt res;

	[self lock];
	res = BKGetAttr (& context, attribute, value);
	[self unlock];

	return res >= 0;
}

- (BOOL)setPointer:(BKCAttr)attribute value:(void *)value size:(NSUInteger)size
{
	BKInt res;

	[self lock];
	res = BKSetPtr (& context, attribute, value, size);
	[self unlock];

	return res >= 0;
}

- (BOOL)getPointer:(BKCAttr)attribute value:(void *)value size:(NSUInteger)size
{
	BKInt res;

	[self lock];
	res = BKGetPtr (& context, attribute, value, size);
	[self unlock];

	return res >= 0;
}

- (BOOL)setIntegerPointer:(BKCAttr)attribute value:(BKInt [])value count:(NSUInteger)count
{
	return [self setPointer:attribute value:value size:sizeof (BKInt) * count];
}

- (BOOL)getIntegerPointer:(BKCAttr)attribute value:(BKInt [])value count:(NSUInteger)count
{
	return [self getPointer:attribute value:value size:sizeof (BKInt) * count];
}

- (BKCAudioUnit *)audioUnit
{
	if (audioUnit == nil) {
		self.audioUnit = [[BKCAudioUnit alloc] initWithNumberOfChannels:self.numberOfChannels sampleRate:self.sampleRate];
	}

	return audioUnit;
}

- (void)setAudioUnit:(BKCAudioUnit *)newAudioUnit
{
	[audioUnit stop];
	audioUnit.delegate = nil;

	audioUnit = newAudioUnit;
	unitLock  = audioUnit.unitLock;

	audioUnit.sampleRate = self.sampleRate;
	audioUnit.delegate   = self;
}

- (void)audioOutputUnitRender:(BKCAudioUnit *)unit outFrames:(SInt16 *)outBuffer numberFrames:(UInt32)inNumberFrames
{
	[self generateFrames:outBuffer numberFrames:inNumberFrames];
}

- (BKInt)generateFrames:(SInt16 *)outBuffer numberFrames:(UInt32)inNumberFrames
{
	return BKContextGenerate (& context, outBuffer, inNumberFrames);
}

@end

@implementation BKCContext (Lock)

- (void)lock
{
	[unitLock lock];
}

- (void)unlock
{
	[unitLock unlock];
}

@end
