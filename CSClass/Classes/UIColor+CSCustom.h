//
//  UIColor+CSCustom.h
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/11.
//

#import <UIKit/UIKit.h>

@interface UIColor (CSCustom)
+ (UIColor *)fromHexValue:(NSUInteger)hex;
+ (UIColor *)fromHexValue:(NSUInteger)hex alpha:(CGFloat)alpha;
+ (UIColor *)fromShortHexValue:(NSUInteger)hex;
+ (UIColor *)fromShortHexValue:(NSUInteger)hex alpha:(CGFloat)alpha;
+ (UIColor *)colorWithString:(NSString *)string;
+ (UIColor *)colorFromHexRGB:(NSString *)inColorString;
@end
