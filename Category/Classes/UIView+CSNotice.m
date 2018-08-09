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
@implementation UIView (CSNotice)
- (UIImageView *)getImgView{
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
        [imgV addGestureRecognizer:[self getGesture]];
    }
    return imgV;
}

- (UITapGestureRecognizer *)getGesture{
     UITapGestureRecognizer *tapGes = objc_getAssociatedObject(self, cs_notice_ges_key);
    if(!tapGes){
        tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cs_reloadData)];
    }
    return tapGes;
}
- (UILabel *)getTitleView{
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
        lb.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 80);
        lb.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.4);
        lb.text = @"暂无数据";
        lb.userInteractionEnabled = YES;
        [lb addGestureRecognizer:[self getGesture]];
        objc_setAssociatedObject(self, cs_notice_title_key, lb, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return lb;
}

- (ReloadBlock)getBlock{
    return objc_getAssociatedObject(self, cs_notice_block_key);
}

- (void)cs_showNoticeText:(NSString *)txt{
    UILabel *lb = [self getTitleView];
    lb.text = txt;
    UIImageView *imgV = [self getImgView];
    if(imgV){
        if(!imgV.superview){
            [self addSubview:imgV];
        }
        lb.frame = CGRectMake(0, CGRectGetMaxY(imgV.frame), CGRectGetWidth(self.frame), 30);
    }else{
        lb.frame = CGRectMake(0, CGRectGetHeight(self.frame) / 3.0, CGRectGetWidth(self.frame), 30);
    }
    if(!lb.superview){
        [self addSubview:lb];
    }
}

- (void)cs_hideNotice{
    UILabel *lb = [self getTitleView];
    if(lb && lb.superview){
        [lb removeFromSuperview];
    }
    UIImageView *imgV = [self getImgView];
    if(imgV && imgV.superview){
        [imgV removeFromSuperview];
    }
    objc_removeAssociatedObjects(self);
}

- (void)cs_setNoticeImg:(UIImageView *)imgView{
     objc_setAssociatedObject(self, cs_notice_img_key, imgView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cs_addTouchReloadBlock:(ReloadBlock)reloadBlock{
    objc_setAssociatedObject(self, cs_notice_block_key, reloadBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cs_reloadData{
    ReloadBlock block =  [self getBlock];
    if(block){
        block();
    }
}

//- (void)dealloc{
//    UILabel *lb = [self getTitleView];
//    UIImageView *imgV = [self getImgView];
//    [lb removeFromSuperview];
//    [imgV removeFromSuperview];
//    objc_removeAssociatedObjects(self);
//}
@end
