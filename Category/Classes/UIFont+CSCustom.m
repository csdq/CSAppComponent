//
//  UIFont+CSCustom.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/18.
//

#import "UIFont+CSCustom.h"

@implementation UIFont (CSCustom)
//字体类
+ (UIFont *)largeFont{
    return [UIFont systemFontOfSize:18];
}

+ (UIFont *)defaultFont{
    return [UIFont systemFontOfSize:16];
}

+ (UIFont *)smallFont{
    return [UIFont systemFontOfSize:14];
}

+ (UIFont *)exSmallFont{
    return [UIFont systemFontOfSize:12];
}
@end
