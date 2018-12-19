//
//  UIView+CSNotice.m
//  CSAppComponent
//
//  Created by Mr.s on 2018/7/16.
//

#import "UIView+CSNotice.h"
#import <objc/runtime.h>
const char * cs_notice_title_key = "cs_notice_title_key";
const char * cs_notice_img_key = "cs_notice_img_key";
const char * cs_notice_block_key = "cs_notice_block_key";
const char * cs_notice_ges_key = "cs_notice_ges_key";
const char * cs_notice_spin_key = "cs_notice_spin_key";
@implementation UIView (CSNotice)
@dynamic cs_spin;

+ (void)load{
     method_exchangeImplementations(class_getInstanceMethod([self class], @selector(layoutSubviews)), class_getInstanceMethod([self class], @selector(cs_notice_layoutSubviews)));
}

- (void)cs_notice_layoutSubviews{
    [self cs_notice_layoutSubviews];
    UIActivityIndicatorView * spin = objc_getAssociatedObject(self, cs_notice_spin_key);
    if(spin){
        spin.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height/2.2);
    }
}
- (void)cs_showLoadState{
    if(self.cs_spin.superview == nil){
        [self addSubview:self.cs_spin];
    }
    if(!self.cs_spin.isAnimating){
        [self bringSubviewToFront:self.cs_spin];
        [self.cs_spin startAnimating];
    }
}
//显示UIActivityIndicatorView
- (void)cs_showLoadStateWithColor:(UIColor *)color{
    self.cs_spin.color = color;
    [self cs_showLoadState];
}

- (void)cs_showLoadStateInCenterOfView:(UIView *)view{
    self.cs_spin.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height/2.0);
    [self cs_showLoadState];
}

- (void)cs_hideLoadState{
    if(self.cs_spin.isAnimating){
        [self.cs_spin stopAnimating];
    }
}

- (UIActivityIndicatorView *)cs_spin{
    UIActivityIndicatorView * spin = objc_getAssociatedObject(self, cs_notice_spin_key);
    if(!spin){
        spin = [UIActivityIndicatorView new];
        spin.hidesWhenStopped = YES;
        spin.frame = CGRectMake(0, 0, 44, 44);
        spin.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.4);
        objc_setAssociatedObject(self, cs_notice_spin_key, spin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return spin;
}

- (UIImageView *)cs_getImgView{
    UIImageView *imgV = objc_getAssociatedObject(self, cs_notice_img_key);
    if(imgV){
        CGRect frame = imgV.frame;
        imgV.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        imgV.center = CGPointMake(self.frame.size.width /2.0f, self.frame.size.height / 2.4);
        imgV.userInteractionEnabled = YES;
        NSArray *gesAry = imgV.gestureRecognizers;
        for (UIGestureRecognizer *ges in gesAry) {
            [imgV removeGestureRecognizer:ges];
        }
        [imgV addGestureRecognizer:[self cs_getGesture]];
    }
    return imgV;
}

- (UITapGestureRecognizer *)cs_getGesture{
     UITapGestureRecognizer *tapGes = objc_getAssociatedObject(self, cs_notice_ges_key);
    if(!tapGes){
        tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cs_reloadData)];
    }
    return tapGes;
}
- (UILabel *)cs_getTitleView{
    UILabel *lb = objc_getAssociatedObject(self, cs_notice_title_key);
    if (!lb){
        lb = [[UILabel alloc] init];
        lb.font = [UIFont systemFontOfSize:14];
        lb.textColor = [UIColor lightGrayColor];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.backgroundColor = [UIColor clearColor];
        lb.numberOfLines = 0;
        lb.contentScaleFactor = 0.7;
        lb.adjustsFontSizeToFitWidth = YES;
        lb.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        lb.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.4);
        lb.text = @"暂无数据";
        lb.userInteractionEnabled = NO;
        [lb addGestureRecognizer:[self cs_getGesture]];
        objc_setAssociatedObject(self, cs_notice_title_key, lb, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return lb;
}

- (ReloadBlock)cs_getBlock{
    return objc_getAssociatedObject(self, cs_notice_block_key);
}

- (void)cs_showNoticeText:(NSString *)txt{
    UILabel *lb = [self cs_getTitleView];
    lb.text = txt;
    UIImageView *imgV = [self cs_getImgView];
    if(imgV){
        if(!imgV.superview){
            [self addSubview:imgV];
        }
        lb.frame = CGRectMake(0, CGRectGetMaxY(imgV.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }else{
        lb.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    if(!lb.superview){
        [self addSubview:lb];
    }
}

- (void)cs_hideNotice{
    UILabel *lb = [self cs_getTitleView];
    if(lb && lb.superview){
        [lb removeFromSuperview];
    }
    UIImageView *imgV = [self cs_getImgView];
    if(imgV && imgV.superview){
        [imgV removeFromSuperview];
    }
//    objc_removeAssociatedObjects(self);
}

- (void)cs_setNoticeImg:(UIImageView *)imgView{
     objc_setAssociatedObject(self, cs_notice_img_key, imgView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cs_addTouchReloadBlock:(ReloadBlock)reloadBlock{
    [self cs_getTitleView].userInteractionEnabled = YES;
    objc_setAssociatedObject(self, cs_notice_block_key, reloadBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cs_reloadData{
    ReloadBlock block =  [self cs_getBlock];
    if(block){
        block();
    }
}
@end
