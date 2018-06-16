//
//  UIImage+CSQRCodeImage.h
//  OAVendors
//
//  Created by Mr.S on 2017/8/31.
//  Copyright © 2017年 csdq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (CSQRCodeImage)
///字符串生成二维码
- (void)setQRCodeWithContent:(NSString *_Nullable)content NS_AVAILABLE(10_9,7_0);
///字符串生成二维码 带logo
- (void)setQRCodeWithContent:(NSString *_Nullable)content logo:(UIImage*_Nullable)logo NS_AVAILABLE(10_9,7_0);
@end
