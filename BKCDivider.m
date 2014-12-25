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

#import "BKCDivider.h"

@interface BKCDivider ()

@property (readwrite) BKCContext * context;

@end

@implementation BKCContext (BKTrackContext)

- (BOOL)attachDivider:(BKCDivider *)divider
{
	if ([dividers containsObject:divider])
		return NO;

	[dividers addObject:divider];
	divider.context = self;

	return YES;
}

- (BOOL)detachDivider:(BKCDivider *)divider
{
	[self lock];

	if (![dividers containsObject:divider]) {
		[self unlock];
		return NO;
	}

	[dividers removeObject:divider];

	[self unlock];

	return YES;
}

@end

@implementation BKCDivider

static IMP dividerMethod;

@synthesize context = context;
@synthesize block;

static BKEnum dividerFunc (BKCallbackInfo * info, void * userInfo)
{
	BKCDivider * self = (__bridge BKCDivider *) userInfo;

	info -> divider = (BKInt)self -> ticks;

	return ((BKEnum (*) (id, SEL, BKCallbackInfo *, void *)) dividerMethod) (self, @selector(invokeBlockWithInfo:userInfo:), info, userInfo);
}

+ (void)initialize
{
	dividerMethod = [self instanceMethodForSelector:@selector(invokeBlockWithInfo:userInfo:)];
}

- (instancetype)init
{
	return [self initWithTicks:24];
}

- (instancetype)initWithTicks:(NSInteger)theTicks
{
	BKCallback callback;

	if ((self = [super init])) {
		callback.func     = dividerFunc;
		callback.userInfo = (__bridge void *) self;

		ticks = theTicks;
		BKDividerInit (& divider, (BKInt)ticks, & callback);
	}

	return self;
}

- (void)dealloc
{
	[context lock];
	BKDividerDetach (& divider);
	[context unlock];
}

- (void)setTicks:(NSInteger)newTicks
{
	ticks = newTicks;
}

- (NSInteger)ticks
{
	return ticks;
}

- (BOOL)attachToContext:(BKCContext *)newContext
{
	BKInt res;

	if (!newContext)
		return NO;

	[context detachDivider:self];

	[newContext lock];

	if (![newContext attachDivider:self]) {
		[context unlock];
		return NO;
	}

	res = BKContextAttachDivider (context.context, & divider, BK_CLOCK_TYPE_BEAT);

	[newContext unlock];

	return res >= 0;
}

- (void)detach
{
	[context lock];

	if ([context detachDivider:self])
		BKDividerDetach (& divider);

	[context unlock];
	context = nil;
}

- (BKEnum)invokeBlockWithInfo:(BKCallbackInfo *)callbackInfo userInfo:(void *)userInfo
{
	if (block)
		return block (context, callbackInfo);

	return 0;
}

@end
