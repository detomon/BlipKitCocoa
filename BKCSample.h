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

@interface BKCSample : NSObject
{
	BKData data;
}

/**
 * Number of frames
 */
@property (readonly, nonatomic) NSUInteger length;

/**
 * Number of channels
 */
@property (readonly, nonatomic) NSUInteger numberOfChannels;

/**
 * Underlaying data object
 */
@property (readonly, nonatomic) BKData * data;

/**
 * Initialize with raw content of file
 */
- (instancetype)initWithRawAudioOfFile:(NSString *)path numberOfChannels:(NSUInteger)numberOfChannels params:(BKEnum)params;

/**
 * Initialize with content of WAVE file
 */
- (instancetype)initWithWAVEFile:(NSString *)path;

/**
 * Initialize with given copy of given data.
 */
- (instancetype)initWithData:(BKData const *)data;

/**
 * Replace frames
 */
- (BKInt)loadFrames:(void const *)frames dataSize:(NSUInteger)dataSize numberOfChannels:(NSUInteger)numberOfChannels params:(BKEnum)params;

@end
