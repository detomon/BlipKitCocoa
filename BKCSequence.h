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

@interface BKCSequence : NSObject
{
	NSUInteger capacity;
	void     * values;
}

/**
 * Number of values
 */
@property (readwrite, nonatomic) NSUInteger length;

/**
 * Number of components per value
 */
@property (readwrite, nonatomic) NSUInteger numberOfComponents;

/**
 * Size of single value
 */
@property (readwrite, nonatomic) NSUInteger valueSize;

/**
 * Initialize with empty values
 */
- (instancetype)initWithLength:(NSUInteger)length numberOfComponents:(NSUInteger)numberOfComponents valueSize:(NSUInteger)valueSize;

/**
 * Replace all values
 */
- (void)replaceValues:(void const *)values length:(NSUInteger)length;

/**
 * Replace values in range
 */
- (void)replaceValuesInRange:(NSRange)range withValues:(void const *)values length:(NSUInteger)length;

/**
 * Get value at index
 */
- (void const *)valuesAtIndex:(NSUInteger)index;

@end
