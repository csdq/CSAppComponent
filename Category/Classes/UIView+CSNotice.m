//
//  UIView+CSNotice.m
//  CSAppComponent
//
//  Created by Mr.s on 2018/7/16.
//

#import "UIView+CSNotice.h"
#import <objc/runtime.h>
const char * cs_notice_view_key = "cs_notice_view_key";
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
    self.cs_spin.center = CGPointMake(view.frame.size.width / 2.0, view.frame.size.height/2.0);
    [self cs_showLoadState];
}

//显示
- (void)cs_showLoadStateWithCenter:(CGPoint)center{
    self.cs_spin.center = center;
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
        objc_setAssociatedObject(self, cs_notice_spin_key, spin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        spin.hidesWhenStopped = YES;
        spin.frame = CGRectMake(0, 0, 44, 44);
        spin.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.4);
    }
    return spin;
}

- (UIImageView *)cs_getImgView{
    UIImageView *imgV = objc_getAssociatedObject(self, cs_notice_img_key);
    if(!imgV){
        imgV = [[UIImageView alloc] init];
        imgV.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) * 0.6, CGRectGetWidth(self.frame) * 0.6);
        imgV.center = CGPointMake(self.frame.size.width /2.0f, self.frame.size.height / 2.4);
    }
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
        lb.frame = CGRectMake(0,
                              CGRectGetMaxY(imgV.frame),
                              CGRectGetWidth(self.frame),
                              MAX(30,CGRectGetHeight(self.frame) - CGRectGetHeight(imgV.frame)));
    }else{
        lb.frame = CGRectMake(0,
                              0,
                              CGRectGetWidth(self.frame),
                              CGRectGetHeight(self.frame) * 0.8);
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
    [self cs_hideNoticeView];
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

///显示提示 图片和文字
- (void)cs_showNotice:(NSString *)txt
                  img:(UIImage *)img{
    UIView * noticeView = [self cs_getNoticeView];
    UIImageView * imgV = (UIImageView *)[noticeView viewWithTag:100];
    imgV.image = img;
    UILabel * lb = (UILabel *)[noticeView viewWithTag:101];
    lb.text = txt;
    noticeView.frame = self.bounds;
    if(!noticeView.superview){
        [self addSubview:noticeView];
    }
}

- (void)cs_hideNoticeView{
    UIView * noticeView = [self cs_getNoticeView];
    if(noticeView.superview){
        [noticeView removeFromSuperview];
    }
}

- (UIView *)cs_getNoticeView{
    UIView *v = objc_getAssociatedObject(self, cs_notice_view_key);
    if (!v){
        v = [[UIView alloc] init];
        v.backgroundColor = [UIColor clearColor];
        v.userInteractionEnabled = NO;
        v.frame = self.bounds;
        [v addGestureRecognizer:[self cs_getGesture]];
        objc_setAssociatedObject(self, cs_notice_view_key, v, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //image
        UIImageView * imgV = [[UIImageView alloc] init];
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        imgV.translatesAutoresizingMaskIntoConstraints = NO;
        imgV.tag = 100;
        [v addSubview:imgV];
        
        //text
        UILabel *lb = [[UILabel alloc] init];
        lb.tag = 101;
        lb.font = [UIFont systemFontOfSize:14];
        lb.textColor = [UIColor lightGrayColor];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.backgroundColor = [UIColor clearColor];
        lb.numberOfLines = 0;
        lb.contentScaleFactor = 0.7;
        lb.adjustsFontSizeToFitWidth = YES;
        lb.text = @"暂无数据";
        lb.userInteractionEnabled = NO;
        [v addSubview:lb];
        lb.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat imgWidth = MIN(120,CGRectGetHeight(self.frame) * 0.4);
        CGFloat margin = (CGRectGetWidth(self.frame)-imgWidth)/2.0;
        [v addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imgV]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgV)]];
        [v addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lb]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lb)]];
        [v addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[imgV(==%f)]-%f-|",margin,imgWidth,margin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgV,lb)]];
         [v addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imgV]-[lb]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgV,lb)]];
        
    }
    return v;
}
@end
