//
//  UIImage+CSCustom.h
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/26.
//

#import <UIKit/UIKit.h>

@interface UIImage (CSCustom)
/*************获取Bundle内的资源文件***************/
///获取bundle内的资源文件
+ (UIImage *)imageNamed:(NSString *)name
               inBundle:(NSBundle *)bundle
                 ofType:(NSString *)type;
///获取bundle内的plist文件
+ (UIImage *)imagePlistNamed:(NSString *)name
                  inBundle:(NSBundle *)bundle;
///获取bundle内的png图片
+ (UIImage *)imagePNGNamed:(NSString *)name
                  inBundle:(NSBundle *)bundle;
///获取bundle内的jpg图片
+ (UIImage *)imageJPGNamed:(NSString *)name
                  inBundle:(NSBundle *)bundle;
@end
