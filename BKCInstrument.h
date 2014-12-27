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
#import "BKCSequence.h"

typedef enum: NSUInteger
{
	BKCSequenceFormatUndefined = 0,
	BKCSequenceFormatSequence,
	BKCSequenceFormatEnvelope,
} BKCSequenceFormat;

@class BKCInstrument;

@interface BKCInstrumentSequence : BKCSequence
{
	__unsafe_unretained BKCInstrument * instrument;
	BKSequence * sequence;
}

/**
 * Sequence type
 */
@property (readonly, nonatomic) BKEnum type;

/**
 * Sequence value format
 */
@property (readonly, nonatomic) BKCSequenceFormat format;

/**
 * Enable/disable sequence
 */
@property (assign, nonatomic) BOOL enabled;

/**
 * Sustain repeat range
 */
@property (assign, nonatomic) NSRange sustainRange;

/**
 * Set sequence values or envelope
 */
- (BOOL)setSequencePhases:(BKInt const *)phases length:(NSUInteger)length sustainRange:(NSRange)sustainRange;
- (BOOL)setEnvelopePhases:(BKSequencePhase const *)phases length:(NSUInteger)length sustainRange:(NSRange)sustainRange;
- (BOOL)setEnvelopeADSR:(NSInteger)attack decay:(NSInteger)decay sustain:(NSInteger)sustain release:(NSInteger)release;

/**
 * Get values
 */
- (BKInt const *)values;
- (BKSequencePhase const *)phases;

@end

@interface BKCInstrument : NSObject
{
	BKInstrument instrument;
	NSMutableArray * sequences;
}

/**
 * Get BlipKit Instrument
 */
@property (readonly, nonatomic) BKInstrument * instrument;

/**
 * Initialize instrument with ADSR volume envelope
 */
- (instancetype)initWithEnvelopeADSR:(NSInteger)attack decay:(NSInteger)decay sustain:(NSInteger)sustain release:(NSInteger)release;

/**
 * Get sequence with type
 */
- (BKCInstrumentSequence *)sequenceWithType:(BKEnum)type;

/**
 * Set ADSR envelope of the volume sequence
 */
- (BOOL)setEnvelopeADSR:(NSInteger)attack decay:(NSInteger)decay sustain:(NSInteger)sustain release:(NSInteger)release;

/**
 * For subclasses
 *
 * Returns class of sequence. Default is `BKCInstrumentSequence`.
 */
+ (Class)sequenceClass;

@end
