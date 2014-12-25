//
//  BKCSequence.m
//  BlipKitCocoa
//
//  Created by Simon Schoenenberger on 21.06.14.
//  Copyright (c) 2014 Simon. All rights reserved.
//

#import "BKCSequence.h"

@implementation BKCSequence

@synthesize valueSize;
@synthesize length;
@synthesize numberOfComponents;

- (instancetype)init
{
	return [self initWithLength:0 numberOfComponents:1 valueSize:0];
}

- (instancetype)initWithLength:(NSUInteger)theLength numberOfComponents:(NSUInteger)theNumberOfComponents valueSize:(NSUInteger)theValueSize
{
	if (self = [super init]) {
		self.valueSize          = theValueSize;
		self.numberOfComponents = theNumberOfComponents;
		self.length             = theLength;
	}

	return self;
}

- (void)dealloc
{
	if (values) {
		free (values);
	}
}

- (BOOL)setCapacity:(NSUInteger)newCapacity
{
	void * newValues;

	if (newCapacity > capacity) {
		newValues = realloc (values, newCapacity);

		if (newValues == NULL) {
			return NO;
		}

		// empty appended bytes
		memset (& newValues [capacity], 0, newCapacity - capacity);

		values   = newValues;
		capacity = newCapacity;

		return YES;
	}

	return YES;
}

- (NSUInteger)length
{
	return length;
}

- (void)setLength:(NSUInteger)newLength
{
	NSUInteger newCapacity;

	newCapacity = newLength * numberOfComponents * valueSize;
	
	if ([self setCapacity:newCapacity] == NO) {
		return;
	}
	
	length = newLength;
}

- (NSUInteger)numberOfComponents
{
	return numberOfComponents;
}

- (void)setNumberOfComponents:(NSUInteger)newNumberOfComponents
{
	NSUInteger newCapacity;

	if (newNumberOfComponents < 1) {
		newNumberOfComponents = 1;
	}

	newCapacity = length * newNumberOfComponents * valueSize;

	if ([self setCapacity:newCapacity] == NO) {
		return;
	}

	numberOfComponents = newNumberOfComponents;
}

- (NSUInteger)valueSize
{
	return valueSize;
}

- (void)setValueSize:(NSUInteger)newValueSize
{
	NSUInteger newCapacity;
	
	if (newValueSize == 0) {
		newValueSize = sizeof (SInt32);
	}
	
	newCapacity = length * numberOfComponents * newValueSize;
	
	if ([self setCapacity:newCapacity] == NO) {
		return;
	}
	
	valueSize = newValueSize;
}

- (void)replaceValues:(void const *)newValues length:(NSUInteger)newLength
{
	return [self replaceValuesInRange:NSMakeRange (0, length) withValues:newValues length:newLength];
}

- (void)replaceValuesInRange:(NSRange)range withValues:(void const *)newValues length:(NSUInteger)valuesLength
{
	NSInteger  oldLength = length;
	NSUInteger groupSize = numberOfComponents * valueSize;

	// clamp range
	range = NSIntersectionRange (range, NSMakeRange (0, oldLength));

	// signed!
	self.length = (NSInteger)oldLength + (NSInteger)valuesLength - (NSInteger)range.length;

	memmove (
		values + (range.location + valuesLength) * groupSize,
		values + (range.location + range.length) * groupSize,
		((NSInteger)oldLength - (NSInteger)range.location - (NSInteger)range.length) * groupSize
	);

	memcpy (
		values + range.location * groupSize,
		newValues,
		valuesLength * groupSize
	);
}

- (void const *)valuesAtIndex:(NSUInteger)index
{
	if (index >= length) {
		return NULL;
	}

	return values + index * numberOfComponents * valueSize;
}

@end
