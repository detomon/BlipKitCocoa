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

#import <AudioUnit/AudioUnit.h>
#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#	import <AudioToolbox/AudioToolbox.h>
#	import <AVFoundation/AVFoundation.h>
#endif

@class BKCAudioUnit;

/**
 * Render block which provides sound data
 */
typedef void (^ BKCAudioUnitRenderBlock) (BKCAudioUnit * unit, SInt16 * outBuffer, UInt32 inNumberFrames);

/**
 * Delegate object on which the render method is called
 */
@protocol BKCAudioUnitDelegate <NSObject>

/**
 * Render method which provides sound data
 */
- (void)audioOutputUnitRender:(BKCAudioUnit *)unit outFrames:(SInt16 *)outBuffer numberFrames:(UInt32)inNumberFrames;

@end

/**
 * Wrapper for audio unit
 */
@interface BKCAudioUnit : NSObject
{
	AudioStreamBasicDescription streamDescription;
	AudioComponentInstance      audioComponent;
	IMP                         delegateMethod;
#if __IPHONE_OS_VERSION_MIN_REQUIRED
	id                          interruptObserver;
#endif
}

/**
 * Sample rate
 */
@property (assign) UInt32 sampleRate;

/**
 * Number of channels
 */
@property (assign) UInt32 numberOfChannels;

/**
 * Delegate
 */
@property (assign) id<BKCAudioUnitDelegate> delegate;

/**
 * Render block
 */
@property (copy) BKCAudioUnitRenderBlock renderBlock;

/**
 * Check if started
 */
@property (readonly) BOOL isStarted;

/**
 * Lock to protect data in render callback
 */
@property (readwrite) NSRecursiveLock * unitLock;

/**
 * Initialize with number of channels and sample rate
 */
- (instancetype)initWithNumberOfChannels:(UInt32)numberOfChannels sampleRate:(UInt32)sampleRate;

/**
 * Start output unit
 *
 * This will call audioOutputUnitRender:flags:timeStamp:busNumber:numberFrames:bufferList:
 * of delegate or the render block (if assigned) every time the sound buffer runs empty
 */
- (BOOL)start;

/**
 * Stop output unit
 */
- (BOOL)stop;

/**
 * Lock access to data which is used by the render callback
 */
- (void)lock;

/**
 * Unlock access to data which is used by the render callback uses
 */
- (void)unlock;

@end
