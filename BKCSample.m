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

#import "BKCSample.h"
#import "BKWaveFileReader.h"

@interface BKCWaveFileReader : NSObject
{
	FILE           * file;
	BKFrame        * frames;
	BKWaveFileReader reader;
	BKInt            numChannels;
	BKInt            numFrames;
	BKInt            sampleRate;
}

- (instancetype)initWithWAVEFile:(NSString *)path;
- (BKInt)readIntoSample:(BKCSample *)sample;

@end

@implementation BKCWaveFileReader

- (instancetype)initWithWAVEFile:(NSString *)path;
{
	BKInt res;

	if (self = [super init]) {
		NSAssert (path != nil, @"Path may not be nil");

		file = fopen (path.UTF8String, "r");

		if (file == nil) {
			NSLog (@"*** Failed to open file: %@", path);
			return nil;
		}

		res = BKWaveFileReaderInit (& reader, file);

		if (res < 0) {
			NSLog (@"*** Failed to initialize WAVE reader: %d", res);
			return nil;
		}
	}

	return self;
}

- (void)dealloc
{
	if (file) {
		fclose (file);
	}

	if (frames) {
		free (frames);
	}
}

- (BKInt)readIntoSample:(BKCSample *)sample
{
	BKInt  res;
	size_t dataSize;

	res = BKWaveFileReaderReadHeader (& reader, & numChannels, & sampleRate, & numFrames);

	if (res < 0) {
		return res;
	}

	dataSize = sizeof (BKFrame) * numChannels * numFrames;
	frames   = malloc (dataSize);

	if (frames == NULL) {
		return -1;
	}

	res = BKWaveFileReaderReadFrames (& reader, frames);

	if (res < 0) {
		return res;
	}

	res = [sample loadFrames:frames dataSize:dataSize numberOfChannels:numChannels params:BK_16_BIT_SIGNED];

	if (res < 0) {
		return res;
	}

	return 0;
}

@end

@implementation BKCSample

- (instancetype)init
{
	if (self = [super init]) {
		BKDataInit (& data);
	}

	return self;
}

- (instancetype)initWithRawAudioOfFile:(NSString *)path numberOfChannels:(NSUInteger)numberOfChannels params:(BKEnum)params
{
	BKInt    res;
	NSData * rawAudio;

	if (self = [self init]) {
		rawAudio = [NSData dataWithContentsOfFile:path];

		if (rawAudio) {
			res = BKDataSetData (& data, rawAudio.bytes, (BKUInt)rawAudio.length, (BKUInt)numberOfChannels, params);

			if (res < 0) {
				NSLog (@"*** Failed to load raw audio: %d", res);
				return nil;
			}
		}
	}

	return self;
}

- (instancetype)initWithWAVEFile:(NSString *)path
{
	BKInt               res;
	BKCWaveFileReader * reader;

	if (self = [self init]) {
		reader = [[BKCWaveFileReader alloc] initWithWAVEFile:path];

		if (reader == nil) {
			NSLog (@"*** Failed to create WAVE file reader");
			return nil;
		}

		res = [reader readIntoSample:self];

		if (res < 0) {
			NSLog (@"*** Failed to read WAVE file: %d", res);
			return nil;
		}
	}

	return self;
}

- (void)dealloc
{
	BKDispose (& data);
}

- (NSUInteger)length
{
	return data.numFrames;
}

- (NSUInteger)numberOfChannels
{
	return data.numChannels;
}

- (BKData *)data
{
	return & data;
}

- (BKInt)loadFrames:(void const *)frames dataSize:(NSUInteger)dataSize numberOfChannels:(NSUInteger)numberOfChannels params:(BKEnum)params
{
	return BKDataSetData (& data, frames, (BKInt)dataSize, (BKInt)numberOfChannels, params);
}

@end
