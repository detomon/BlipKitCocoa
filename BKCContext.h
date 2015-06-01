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
 * FITNESS FOR A PARTICULAR PURPOSE AND . IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "BlipKit.h"
#import "BKCAudioUnit.h"
#import "BKCBase.h"

@interface BKCContext : NSObject <BKCAttributes, BKCAudioUnitDelegate>
{
	BKContext        context;
	NSMutableArray * tracks;
	NSMutableArray * dividers;
}

/**
 * The underlaying BlipKit context
 */
@property (readonly, nonatomic)  BKContext * context;

/**
 * An array of attached tracks
 */
@property (readonly, nonatomic)  NSArray * tracks;

/**
 * An audio unit which can be used to output audio
 *
 * If no one is assigned one is created
 */
@property (readwrite, nonatomic)  BKCAudioUnit * audioUnit;

/**
 * The lock which is used to protect BlipKit calls
 *
 * This is the same as that of the audioUnit
 */
@property (readonly, nonatomic) NSRecursiveLock * unitLock;

/**
 * The sample rate
 */
@property (readonly, nonatomic) UInt32 sampleRate;

/**
 * The number of channels
 */
@property (readonly, nonatomic) UInt32 numberOfChannels;

/**
 * Number of ticks per second
 */
@property (readwrite, nonatomic) UInt32 clockPeriod;

/**
 * Initialize with number of channels and sample rate
 *
 * The supported range goes from 16000 to 96000
 */
- (instancetype)initWithNumberOfChannels:(UInt32)numberOfChannels sampleRate:(UInt32)sampleRate;

/**
 * Generate frames and copy to `outBuffer`
 *
 * Buffer must have have space for inNumberFrames * numberOfChannels frames
 */
- (BKInt)generateFrames:(SInt16 *)outBuffer numberFrames:(UInt32)inNumberFrames;

/**
 * Calls audioUnit's start method
 */
- (BOOL)start;

/**
 * Calls audioUnit's stop method
 */
- (BOOL)stop;

/**
 * Reset underlaying BlipKit context
 */
- (void)reset;

@end

/**
 * Locking methods
 */
@interface BKCContext (Lock)

- (void)lock;
- (void)unlock;

@end
