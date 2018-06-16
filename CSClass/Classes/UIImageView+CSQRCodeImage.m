//
//  UIImage+CSQRCodeImage.m
//  OAVendors
//
//  Created by Mr.S on 2017/8/31.
//  Copyright © 2017年 csdq. All rights reserved.
//

#import "UIImageView+CSQRCodeImage.h"
#define QRCODE_DEFAULT_SIZE CGSizeMake(200, 200)
@implementation UIImageView (CSQRCodeImage)
- (void)setQRCodeWithContent:(NSString *)content{
    [self setQRCodeWithContent:content logo:nil];
}

- (void)setQRCodeWithContent:(NSString *)content logo:(UIImage *)logo{
    if(!content){
        content = @"";
    }
    self.backgroundColor = [UIColor clearColor];
    CIFilter *filterImage = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filterImage setDefaults];
    NSData *dataImage = [content dataUsingEncoding:NSUTF8StringEncoding];
    [filterImage setValue:dataImage forKey:@"inputMessage"];
    [filterImage setValue:@"Q" forKey:@"inputCorrectionLevel"];
    CIImage *outputImage = [filterImage outputImage];
    
    CGSize imgSize = self.frame.size;
    if(imgSize.width == 0 || imgSize.height == 0){
        imgSize = QRCODE_DEFAULT_SIZE;
    }
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(imgSize.width / outputImage.extent.size.width * [UIScreen mainScreen].scale,imgSize.height / outputImage.extent.size.height * [UIScreen mainScreen].scale)];
    UIImage *image = [UIImage imageWithCIImage:outputImage];
    
    if(logo){
        UIGraphicsBeginImageContext(image.size);
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height) cornerRadius:imgSize.width * 0.1f] addClip];
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        CGSize logoSize = CGSizeMake(logo.size.width * [UIScreen mainScreen].scale,logo.size.height * [UIScreen mainScreen].scale);
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake((image.size.width - logoSize.width) / 2.0f, (image.size.height - logoSize.height) / 2.0f, logoSize.width, logoSize.height) cornerRadius:logoSize.width * 0.1f] addClip];
        [logo drawInRect:CGRectMake((image.size.width - logoSize.width) / 2.0f, (image.size.height - logoSize.height) / 2.0f , logoSize.width,logoSize.height)];
        UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.image = resultImg;
    }else{
        self.image = image;
    }
}
@end
