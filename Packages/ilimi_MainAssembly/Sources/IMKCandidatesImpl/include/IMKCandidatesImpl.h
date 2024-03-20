//
//  ilimi-Bridging-Header.h
//  ilimi
//
//  Created by 陳奕利 on 2022/9/10.
//

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
