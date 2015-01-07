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
#import "BKCContext.h"

@interface BKCDivider : NSObject
{
	BKDivider divider;
	NSInteger ticks;
	__unsafe_unretained BKCContext * context;
}

/**
 * The context which this divider is attached to
 */
@property (readonly, nonatomic) BKCContext * context;

/**
 * Block which is called every specified number of ticks
 */
@property (copy, nonatomic) BKInt (^ block) (BKCContext * context, BKCallbackInfo * callbackInfo);

/**
 * Number of ticks
 */
@property (readwrite, nonatomic) NSInteger ticks;

/**
 * Initialize with number of ticks
 */
- (instancetype)initWithTicks:(NSInteger)ticks;

/**
 * Attach to context
 */
- (BOOL)attachToContext:(BKCContext *)context;

/**
 * Detach from context
 */
- (void)detach;

@end
