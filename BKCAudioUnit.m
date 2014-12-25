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

#import "BKCAudioUnit.h"

#define DEFAULT_NUM_CHANNELS 2
#define DEFAULT_SAMPLE_RATE 44100
#define DEFAULT_NUM_BITS 16

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#	define AUDIO_COMPONENT_SUB_TYPE kAudioUnitSubType_RemoteIO
#else
#	define AUDIO_COMPONENT_SUB_TYPE kAudioUnitSubType_DefaultOutput
#endif

typedef OSStatus (* BKCDelegateMethodFunc) (id, SEL, id, SInt16 *, UInt32);

@interface BKCAudioUnit ()

@property (assign) BOOL isStarted;

@end

@implementation BKCAudioUnit

static SEL delegateSelector;

@synthesize sampleRate;
@synthesize numberOfChannels;
@synthesize delegate;
@synthesize renderBlock;
@synthesize unitLock;
@synthesize isStarted;

+ (void)initialize
{
	delegateSelector = @selector(audioOutputUnitRender:outFrames:numberFrames:);
}

- (BOOL)initializeStreamDescription
{
	OSErr err;

	streamDescription.mSampleRate       = sampleRate;
	streamDescription.mFormatID         = kAudioFormatLinearPCM;
	streamDescription.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
	streamDescription.mBitsPerChannel   = DEFAULT_NUM_BITS;
	streamDescription.mChannelsPerFrame = numberOfChannels;
	streamDescription.mBytesPerFrame    = numberOfChannels * DEFAULT_NUM_BITS / 8;
	streamDescription.mFramesPerPacket  = 1;
	streamDescription.mBytesPerPacket   = streamDescription.mFramesPerPacket * streamDescription.mBytesPerFrame;

	AudioUnitUninitialize (audioComponent);

	err = AudioUnitSetProperty (
		audioComponent,
		kAudioUnitProperty_StreamFormat,
		kAudioUnitScope_Input,
		0,
		& streamDescription,
		sizeof(AudioStreamBasicDescription)
	);

	if (err != noErr) {
		NSLog (@"*** Error setting stream format: %d", err);
		return NO;
	}

	err = AudioUnitInitialize (audioComponent);

	if (err != noErr) {
		NSLog (@"*** Error initializing stream description: %d", err);
		return NO;
	}

	return YES;
}

static OSStatus renderCallback (BKCAudioUnit * self, AudioUnitRenderActionFlags * ioActionFlags, const AudioTimeStamp * inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList * ioData)
{
	SInt16              * outFrames;
	AudioBuffer         * buffer;
	UInt32                numberFrames;
	BKCDelegateMethodFunc callback;

	for (NSInteger i = 0; i < ioData -> mNumberBuffers; i ++) {
		buffer       = & ioData -> mBuffers [i];
		numberFrames = buffer -> mDataByteSize / buffer -> mNumberChannels / sizeof (SInt16);
		outFrames    = (SInt16 *) buffer -> mData;

		[self lock];
		{
			callback = (void *) self -> delegateMethod;

			if (self -> renderBlock) {
				self -> renderBlock (self, outFrames, numberFrames);
			}
			else if (callback) {
				callback (self -> delegate, delegateSelector, self, outFrames, numberFrames);
			}
		}
		[self unlock];
	}

	return noErr;
}

- (instancetype)init
{
	return [self initWithNumberOfChannels:DEFAULT_NUM_CHANNELS sampleRate:DEFAULT_SAMPLE_RATE];
}

- (instancetype)initWithNumberOfChannels:(UInt32)theNumberOfChannels sampleRate:(UInt32)theSampleRate
{
	OSErr err;
	AudioComponentDescription defaultOutputDescription;
	AudioComponent defaultOutput;

	if ((self = [super init])) {
		unitLock = [[NSRecursiveLock alloc] init];

		numberOfChannels = theNumberOfChannels;
		sampleRate       = theSampleRate;

		memset (& defaultOutputDescription, 0, sizeof (defaultOutputDescription));

		defaultOutputDescription.componentType         = kAudioUnitType_Output;
		defaultOutputDescription.componentSubType      = AUDIO_COMPONENT_SUB_TYPE;
		defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
		defaultOutput = AudioComponentFindNext (NULL, & defaultOutputDescription);

		if (defaultOutput == NULL) {
			NSLog (@"*** Not audio component for output found");
			return nil;
		}

		if (defaultOutput) {
			err = AudioComponentInstanceNew (defaultOutput, & audioComponent);

			if (audioComponent == NULL) {
				NSLog (@"*** Error creating audio unit: %d", err);
				return nil;
			}

			if ([self initializeStreamDescription] == NO) {
				return nil;
			}
		}
	}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
	__weak BKCAudioUnit * _self = self;

	interruptObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionInterruptionNotification
																		  object:[AVAudioSession sharedInstance]
																		   queue:[NSOperationQueue mainQueue]
																	  usingBlock:^(NSNotification *note) {
																		  [_self stop];
																	  }];
#endif

	return self;
}

- (void)dealloc
{
	[self stop];
	AudioComponentInstanceDispose (audioComponent);

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
	[[NSNotificationCenter defaultCenter] removeObserver:interruptObserver];
#endif
}

- (UInt32)sampleRate
{
	return sampleRate;
}

- (void)setSampleRate:(UInt32)newSampleRate
{
	sampleRate = newSampleRate;

	if ([self initializeStreamDescription] == NO) {
		NSLog (@"*** Error setting sample rate");
	}
}

- (id<BKCAudioUnitDelegate>)delegate
{
	return delegate;
}

- (void)setDelegate:(id<BKCAudioUnitDelegate>)newDelegate
{
	[self lock];

	delegateMethod = [(id) newDelegate methodForSelector:delegateSelector];

	if (delegateMethod) {
		delegate = newDelegate;
	}
	else {
		NSLog (@"*** Delegate does not implement %s", sel_getName(delegateSelector));
	}

	[self unlock];
}

- (BKCAudioUnitRenderBlock)renderBlock
{
	return [renderBlock copy];
}

- (void)setRenderBlock:(BKCAudioUnitRenderBlock)newRenderBlock
{
	[self lock];
	renderBlock = [newRenderBlock copy];
	[self unlock];
}

- (BOOL)start
{
	OSErr err;
	AURenderCallbackStruct input;

	if (delegate == nil && renderBlock == NULL) {
		NSLog (@"*** No delegate set");
		return NO;
	}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
	NSError * error = nil;
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];

	if ([audioSession setCategory:AVAudioSessionCategorySoloAmbient error:& error] == NO) {
		NSLog(@"Error setting audio category: %@", error);
		return NO;
	}

	if ([audioSession setActive:YES error:& error] == NO) {
		NSLog(@"AudioSession error: %@", error);
		return NO;
	}
#endif

	memset (& input, 0, sizeof (input));

	input.inputProc       = (AURenderCallback) renderCallback;
	input.inputProcRefCon = (__bridge void *)(self);

	err = AudioUnitSetProperty (
		audioComponent,
		kAudioUnitProperty_SetRenderCallback,
		kAudioUnitScope_Input,
		0,
		& input,
		sizeof (input)
	);

	if (err != noErr) {
		NSLog (@"*** Error setting render callback: %d", err);
		return NO;
	}

	err = AudioOutputUnitStart (audioComponent);

	if (err != noErr) {
		NSLog (@"*** Error starting unit: %d", err);
		return NO;
	}

	self.isStarted = YES;

	return YES;
}

- (BOOL)stop
{
	OSErr err;
	AURenderCallbackStruct input;

	err = AudioOutputUnitStop (audioComponent);

	if (err != noErr) {
		NSLog (@"*** Error stopping unit: %d", err);
		return NO;
	}

	self.isStarted = NO;

	memset (& input, 0, sizeof (input));

	input.inputProc       = NULL;
	input.inputProcRefCon = NULL;

	err = AudioUnitSetProperty (
		audioComponent,
		kAudioUnitProperty_SetRenderCallback,
		kAudioUnitScope_Input,
		0,
		& input,
		sizeof (input)
	);

	if (err != noErr) {
		NSLog (@"*** Error unsetting render callback: %d", err);
		return NO;
	}

	return YES;
}

- (void)lock
{
	[unitLock lock];
}

- (void)unlock
{
	[unitLock unlock];
}

@end
