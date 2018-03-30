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
#import "BKCBase.h"

@class BKCTrack;

@interface BKCWaveform : BKCSequence
{
	BKData data;
}

/**
 * Waveform type
 */
@property (readonly, nonatomic) BKCAttr type;

/**
 * Underlaying data object
 */
@property (readonly, nonatomic) BKData * data;

/**
 * Get square waveform
 */
+ (instancetype)squareWaveform;

/**
 * Get triangle waveform
 */
+ (instancetype)triangleWaveform;

/**
 * Get noise waveform
 */
+ (instancetype)noiseWaveform;

/**
 * Get sawtooth waveform
 */
+ (instancetype)sawtoothWaveform;

/**
 * Get sine waveform
 */
+ (instancetype)sineWaveform;

/**
 * Initialize custom waveform with values
 *
 * At least 2 values must be given
 */
- (instancetype)initWithValues:(BKFrame const *)values length:(NSUInteger)length;

/**
 * Initialize with given copy of given data.
 */
- (instancetype)initWithData:(BKData const *)data;

/**
 * Set new values
 *
 * At least 2 values must be given
 */
- (BOOL)setValues:(BKFrame const *)values length:(NSUInteger)length;

@end
