//
//  UIImage+CSCustom.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/26.
//

#import "UIImage+CSCustom.h"

@implementation UIImage (CSCustom)
+ (UIImage *)imageNamed:(NSString *)name
               inBundle:(NSBundle *)bundle
                 ofType:(NSString *)type{
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:type]];
}

+ (UIImage *)imagePlistNamed:(NSString *)name
                  inBundle:(NSBundle *)bundle{
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"plist"]];
}

+ (UIImage *)imagePNGNamed:(NSString *)name
                  inBundle:(NSBundle *)bundle{
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
}

+ (UIImage *)imageJPGNamed:(NSString *)name
                  inBundle:(NSBundle *)bundle{
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"jpg"]];
}
@end
