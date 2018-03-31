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

#import "BKCInstrument.h"
#import "BKCTrack.h"

@interface BKCInstrument ()

- (void)initSequence;

- (void)updateSequence:(BKCInstrumentSequence *)sequence;

@end

@implementation BKCInstrumentSequence

@synthesize type;

- (instancetype)initWithType:(BKEnum)theType instrument:(BKCInstrument *)theInstrument
{
	if ((self = [super init])) {
		type       = theType;
		instrument = theInstrument;
	}

	return self;
}

- (void)dealloc
{
	if (sequence) {
		free (sequence);
	}
}

- (BKCSequenceFormat)format
{
	if (sequence) {
		if (sequence -> funcs == & BKSequenceFuncsSimple) {
			return BKCSequenceFormatSequence;
		}
		else if (sequence -> funcs == & BKSequenceFuncsEnvelope) {
			return BKCSequenceFormatEnvelope;
		}
	}

	return BKCSequenceFormatUndefined;
}

- (BKCInstrument *)instrument
{
	return instrument;
}

- (void)updateSequence
{
	BKInstrument * instr = instrument.instrument;

	sequence = (void *) BKInstrumentGetSequence (instr, type);

	if (sequence)
		sequence -> funcs -> copy (& sequence, sequence);

	[instrument updateSequence:self];
}

- (BOOL)setSequencePhases:(BKInt const *)newPhases length:(NSUInteger)newLength sustainRange:(NSRange)sustainRange
{
	BKInstrument * instr = instrument.instrument;

	if (BKInstrumentSetSequence (instr, type, newPhases, (BKInt)newLength, (BKInt)sustainRange.location, (BKInt)sustainRange.length) < 0) {
		return NO;
	}

	[self updateSequence];

	self.numberOfComponents = 1;
	[self replaceValues:sequence -> values length:sequence -> length];

	return YES;
}

- (BOOL)setEnvelopePhases:(BKSequencePhase const *)newPhases length:(NSUInteger)newLength sustainRange:(NSRange)sustainRange
{
	BKInstrument * instr = instrument.instrument;

	if (BKInstrumentSetEnvelope (instr, type, newPhases, (BKInt)newLength, (BKInt)sustainRange.location, (BKInt)sustainRange.length) < 0) {
		return NO;
	}

	[self updateSequence];

	self.numberOfComponents = 2;
	[self replaceValues:sequence -> values length:sequence -> length];

	return YES;
}

- (BOOL)setEnvelopeADSR:(NSInteger)attack decay:(NSInteger)decay sustain:(NSInteger)sustain release:(NSInteger)release
{
	BKInstrument * instr;

	if (type != BK_SEQUENCE_VOLUME)
		return NO;

	instr = instrument.instrument;

	if (BKInstrumentSetEnvelopeADSR (instr, (BKInt)attack, (BKInt)decay, (BKInt)sustain, (BKInt)release)) {
		return NO;
	}

	[self updateSequence];

	self.numberOfComponents = 2;
	[self replaceValues:sequence -> values length:sequence -> length];

	return YES;
}

- (BKInt const *)values
{
	if (sequence == NULL || self.format != BKCSequenceFormatSequence)
		return NULL;

	return sequence -> values;
}

- (BKSequencePhase const *)phases
{
	if (sequence == NULL || self.format != BKCSequenceFormatEnvelope)
		return NULL;

	return sequence -> values;
}

@end

@implementation BKCInstrument

- (instancetype)init
{
	BKInt res;

	if ((self = [super init])) {
		res = BKInstrumentAlloc (& instrument);

		if (res < 0) {
			NSLog (@"*** Couldn't initialize BKInstrument: %d", res);
			return nil;
		}

		[self initSequence];
	}

	return self;
}

- (instancetype)initWithInstrument:(BKInstrument const *)theInstrument
{
	BKInt res;

	if (self = [self init]) {
		BKObject object;
		res = BKInstrumentAlloc (& instrument);

		if (res < 0) {
			NSLog (@"*** Couldn't initialize BKInstrument: %d", res);
			return nil;
		}

		memcpy (&object, &instrument->object, sizeof(object));
		res = BKInstrumentInitCopy (instrument, theInstrument);
		memcpy (&instrument->object, &object, sizeof(object));

		[self initSequence];
	}

	return self;
}

- (void)initSequence
{
	BKCInstrumentSequence * sequence;
	Class sequenceClass;

	sequences = [[NSMutableArray alloc] initWithCapacity:BK_MAX_SEQUENCES];
	sequenceClass = [[self class] sequenceClass];

	for (NSInteger i = 0; i < BK_MAX_SEQUENCES; i ++) {
		sequence = [[sequenceClass alloc] initWithType:(BKEnum)i instrument:self];
		[sequences addObject:sequence];
	}
}

- (void)dealloc
{
	BKDispose (instrument);
}

- (BKInstrument *)instrument
{
	return instrument;
}

- (BKCInstrumentSequence *)sequenceWithType:(BKEnum)type
{
	if (type >= BK_MAX_SEQUENCES)
		return nil;

	return [sequences objectAtIndex:type];
}

- (void)updateSequence:(BKCInstrumentSequence *)sequence
{
}

- (BOOL)setEnvelopeADSR:(NSInteger)attack decay:(NSInteger)decay sustain:(NSInteger)sustain release:(NSInteger)release
{
	return [[self sequenceWithType:BK_SEQUENCE_VOLUME] setEnvelopeADSR:attack decay:decay sustain:sustain release:release];
}

+ (Class)sequenceClass
{
	return [BKCInstrumentSequence class];
}

@end
