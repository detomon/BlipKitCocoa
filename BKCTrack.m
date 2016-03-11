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

#import "BKCTrack.h"
#import "BKCContext.h"

@interface BKCTrack ()

@property (readwrite) BKCContext * context;

@end

@implementation BKCContext (BKTrackContext)

- (BOOL)attachTrack:(BKCTrack *)track
{
	if ([tracks containsObject:track])
		return NO;

	[tracks addObject:track];
	track.context = self;

	return YES;
}

- (BOOL)detachTrack:(BKCTrack *)track
{
	[self lock];

	if (![tracks containsObject:track]) {
		[self unlock];
		return NO;
	}

	[tracks removeObject:track];

	[self unlock];

	return YES;
}

@end

@implementation BKCTrack

@synthesize context = context;

- (instancetype)init
{
	return [self initWithWaveform:[BKCWaveform squareWaveform]];
}

- (instancetype)initWithWaveform:(BKCWaveform *)theWaveform
{
	if ((self = [super init])) {
		self.waveform = theWaveform;
	}

	return self;
}

- (void)dealloc
{
	[context lock];
	BKDispose (track);
	[context unlock];
}

- (BKTrack *)track
{
	if (!track) {
		BKInt res = BKTrackAlloc (& track, BK_SQUARE);

		if (res < 0) {
			NSLog (@"*** Couldn't initialize BKTrack: %d", res);
			return nil;
		}
	}

	return track;
}

- (void)setTrack:(BKTrack *)newTrack
{
	if (newTrack) {
		[context lock];
		track = newTrack;
		[context unlock];
	}
}

- (BKCInstrument *)instrument
{
	return instrument;
}

- (void)setInstrument:(BKCInstrument *)newInstrument
{
	[context lock];

	instrument = newInstrument;
	BKSetPtr (self.track, BK_INSTRUMENT, instrument.instrument, 0);

	[context unlock];
}

- (BKCWaveform *)waveform
{
	return waveform;
}

- (void)setWaveform:(BKCWaveform *)newWaveform
{
	[context lock];

	if (newWaveform == nil)
		newWaveform = [BKCWaveform squareWaveform];

	waveform = newWaveform;

	if (waveform.type == BK_CUSTOM) {
		BKSetPtr (self.track, BK_WAVEFORM, waveform.data, 0);
	}
	else {
		BKSetAttr (self.track, BK_WAVEFORM, waveform.type);
	}

	[context unlock];
}

- (BKCSample *)sample
{
	return sample;
}

- (void)setSample:(BKCSample *)newSample
{
	[context lock];

	sample = newSample;

	BKSetPtr (self.track, BK_SAMPLE, newSample.data, 0);

	[context unlock];
}

- (BOOL)attachToContext:(BKCContext *)newContext
{
	BKInt res;

	if (!newContext)
		return NO;

	[context detachTrack:self];

	[newContext lock];

	if (![newContext attachTrack:self])
		return NO;

	res = BKTrackAttach (track, context.renderContext);

	[newContext unlock];

	return res >= 0;
}

- (void)detach
{
	[context lock];

	if ([context detachTrack:self])
		BKTrackDetach (track);

	[context unlock];
	context = nil;
}

- (void)reset
{
	[context lock];
	BKTrackReset (track);
	[context unlock];
}

- (BOOL)setAttribute:(BKCAttr)attribute value:(BKInt)value
{
	BKInt res;

	[context lock];
	res = BKSetAttr (self.track, attribute, value);
	[context unlock];

	return res >= 0;
}

- (BOOL)getAttribute:(BKCAttr)attribute value:(BKInt *)value
{
	BKInt res;

	[context lock];
	res = BKGetAttr (self.track, attribute, value);
	[context unlock];

	return res >= 0;
}

- (BOOL)setPointer:(BKCAttr)attribute value:(void *)value size:(NSUInteger)size
{
	BKInt res;

	[context lock];

	if (attribute & BK_EFFECT_TYPE) {
		res = BKTrackSetEffect (track, attribute, value, (BKInt)size);
	}
	else {
		res = BKSetPtr (self.track, attribute, value, size);
	}
	
	[context unlock];

	return res >= 0;
}

- (BOOL)getPointer:(BKCAttr)attribute value:(void *)value size:(NSUInteger)size
{
	BKInt res;

	[context lock];

	if (attribute & BK_EFFECT_TYPE) {
		res = BKTrackGetEffect (track, attribute, value, (BKInt)size);
	}
	else {
		res = BKGetPtr (self.track, attribute, value, size);
	}

	[context unlock];

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

- (BKInt)setEffect:(BKCAttr)effect values:(BKInt const [3])values
{
	return BKTrackSetEffect (track, effect, values, (BKInt)sizeof (BKInt [3]));
}

- (BKInt)getEffect:(BKCAttr)effect values:(BKInt [3])values
{
	return BKTrackGetEffect (track, effect, values, sizeof (BKInt [3]));
}

@end
