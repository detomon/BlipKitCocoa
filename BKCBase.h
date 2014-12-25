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

/**
 * The following types are defined to be usable in Swift
 */

#define BKCMaxVolume 32767

#define BKCFInt20Unit  1048576
#define BKCFInt20Shift BK_FINT20_SHIFT

#define BKCNoRepeat   BK_NO_REPEAT
#define BKCRepeat     BK_REPEAT
#define BKCPalindrome BK_PALINDROME

typedef NS_ENUM(NSInteger, BKCAttr)
{
	BKCAttrContextAttrType       = BK_CONTEXT_ATTR_TYPE,
	BKCAttrAttrTypeShift         = BK_ATTR_TYPE_SHIFT,
	BKCAttrNumChannels           = BK_NUM_CHANNELS,
	BKCAttrSampleRate            = BK_SAMPLE_RATE,
	BKCAttrTime                  = BK_TIME,
	BKCAttrTrackAttrType         = BK_TRACK_ATTR_TYPE,
	BKCAttrWaveform              = BK_WAVEFORM,
	BKCAttrDutyCycle             = BK_DUTY_CYCLE,
	BKCAttrPeriod                = BK_PERIOD,
	BKCAttrPhase                 = BK_PHASE,
	BKCAttrPhaseWrap             = BK_PHASE_WRAP,
	BKCAttrNumPhases             = BK_NUM_PHASES,
	BKCAttrMasterVolume          = BK_MASTER_VOLUME,
	BKCAttrVolume                = BK_VOLUME,
	BKCAttrVolume0               = BK_VOLUME_0,
	BKCAttrVolume1               = BK_VOLUME_1,
	BKCAttrVolume2               = BK_VOLUME_2,
	BKCAttrVolume3               = BK_VOLUME_3,
	BKCAttrVolume4               = BK_VOLUME_4,
	BKCAttrVolume5               = BK_VOLUME_5,
	BKCAttrVolume6               = BK_VOLUME_6,
	BKCAttrVolume7               = BK_VOLUME_7,
	BKCAttrMute                  = BK_MUTE,
	BKCAttrPitch                 = BK_PITCH,
	BKCAttrSampleRange           = BK_SAMPLE_RANGE,
	BKCAttrSampleRepeat          = BK_SAMPLE_REPEAT,
	BKCAttrSamplePeriod          = BK_SAMPLE_PERIOD,
	BKCAttrSamplePitch           = BK_SAMPLE_PITCH,
	BKCAttrSampleCallback        = BK_SAMPLE_CALLBACK,
	BKCAttrNote                  = BK_NOTE,
	BKCAttrArpeggio              = BK_ARPEGGIO,
	BKCAttrPanning               = BK_PANNING,
	BKCAttrInstrument            = BK_INSTRUMENT,
	BKCAttrClockPeriod           = BK_CLOCK_PERIOD,
	BKCAttrArpeggioDivider       = BK_ARPEGGIO_DIVIDER,
	BKCAttrEffectDivider         = BK_EFFECT_DIVIDER,
	BKCAttrInstrumentDivider     = BK_INSTRUMENT_DIVIDER,
	BKCAttrTriangleIgnoresVolume = BK_TRIANGLE_IGNORES_VOLUME,
	BKCAttrHaltSilentPhase       = BK_HALT_SILENT_PHASE,
	BKCAttrDataAttrType          = BK_DATA_ATTR_TYPE,
	BKCAttrNumFrames             = BK_NUM_FRAMES,
	BKCAttrWaveformType          = BK_WAVEFORM_TYPE,
	BKCAttrSquare                = BK_SQUARE,
	BKCAttrTriangle              = BK_TRIANGLE,
	BKCAttrNoise                 = BK_NOISE,
	BKCAttrSawtooth              = BK_SAWTOOTH,
	BKCAttrCustom                = BK_CUSTOM,
	BKCAttrSample                = BK_SAMPLE,
	BKCAttrEffectType            = BK_EFFECT_TYPE,
	BKCAttrEffectVolumeSlide     = BK_EFFECT_VOLUME_SLIDE,
	BKCAttrEffectPanningSlide    = BK_EFFECT_PANNING_SLIDE,
	BKCAttrEffectPortamento      = BK_EFFECT_PORTAMENTO,
	BKCAttrEffectTremolo         = BK_EFFECT_TREMOLO,
	BKCAttrEffectVibrato         = BK_EFFECT_VIBRATO,
	BKCAttrEventType             = BK_EVENT_TYPE,
	BKCAttrEventClock            = BK_EVENT_CLOCK,
	BKCAttrEventDivider          = BK_EVENT_DIVIDER,
	BKCAttrEventSampleBegin      = BK_EVENT_SAMPLE_BEGIN,
	BKCAttrEventSampleReset      = BK_EVENT_SAMPLE_RESET,
};

/**
 *
 */
@protocol BKCAttributes

- (BOOL)setAttribute:(BKCAttr)attribute value:(BKInt)value;
- (BOOL)getAttribute:(BKCAttr)attribute value:(BKInt *)value;

- (BOOL)setPointer:(BKCAttr)attribute value:(void *)value size:(NSUInteger)size;
- (BOOL)getPointer:(BKCAttr)attribute value:(void *)value size:(NSUInteger)size;

- (BOOL)setIntegerPointer:(BKCAttr)attribute value:(BKInt [])value count:(NSUInteger)count;
- (BOOL)getIntegerPointer:(BKCAttr)attribute value:(BKInt [])value count:(NSUInteger)count;

@end
