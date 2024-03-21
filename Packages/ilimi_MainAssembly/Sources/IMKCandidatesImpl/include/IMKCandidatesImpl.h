// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

#ifndef ilimi_Bridging_Header_h
#define ilimi_Bridging_Header_h

#endif /* ilimi_Bridging_Header_h */

//#import <appkit/NSEvent.h>
#import <InputMethodKit/InputMethodKit.h>

@interface IMKCandidates (ilimi) {
}

- (unsigned long long)windowLevel;  // Please do not use perform-selector with this since it will return a null value.
- (void)setWindowLevel:(unsigned long long)level;  // Please do not use perform-selector with this since it never works.
- (void)setFontSize:(double)fontSize;
@end
