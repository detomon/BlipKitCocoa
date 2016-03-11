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
#import "BlipKit.h"
#import "BKCBase.h"
#import "BKCInstrument.h"
#import "BKCSample.h"
#import "BKCWaveform.h"
#import "BKCSample.h"

@class BKCContext;

@interface BKCTrack : NSObject <BKCAttributes>
{
	BKTrack                        * track;
	__unsafe_unretained BKCContext * context;
	BKCInstrument                  * instrument;
	BKCWaveform                    * waveform;
	BKCSample                      * sample;
}

/**
 * The context which this track is attached to
 */
@property (readonly, nonatomic) BKCContext * context;

/**
 * The underlaying BlipKit track
 */
@property (readwrite, nonatomic) BKTrack * track;

/**
 * Current instrument
 */
@property (readwrite, nonatomic) BKCInstrument * instrument;

/**
 * Current custom waveform object
 */
@property (readwrite, nonatomic) BKCWaveform * waveform;

/**
 * Current sample object
 */
@property (readwrite, nonatomic) BKCSample * sample;

/**
 * Initialize with waveform
 */
- (instancetype)initWithWaveform:(BKCWaveform *)waveform;

/**
 * Attach track to context
 */
- (BOOL)attachToContext:(BKCContext *)context;

/**
 * Detach from context
 */
- (void)detach;

/**
 * Set effect values
 */
- (BKInt)setEffect:(BKCAttr)effect values:(BKInt const [3])values;

/**
 * Get effect values
 */
- (BKInt)getEffect:(BKCAttr)effect values:(BKInt [3])values;

/**
 * Reset underlaying BlipKit track
 */
- (void)reset;

@end
