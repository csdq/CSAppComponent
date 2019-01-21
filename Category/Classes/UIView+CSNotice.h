//
//  UIView+CSNotice.h
//  CSAppComponent
//
//  Created by Mr.s on 2018/7/16.
//

#import <UIKit/UIKit.h>

typedef void(^ReloadBlock)(void);
@interface UIView (CSNotice)
@property (nonatomic,strong) UIActivityIndicatorView * cs_spin;
//显示UIActivityIndicatorView
- (void)cs_showLoadState;
//显示
- (void)cs_showLoadStateWithColor:(UIColor *)color;
//显示
- (void)cs_showLoadStateInCenterOfView:(UIView *)view;
//显示
- (void)cs_showLoadStateWithCenter:(CGPoint)center;
//隐藏UIActivityIndicatorView
- (void)cs_hideLoadState;
///显示提示（如果设置了图片则显示图片和文字）
- (void)cs_showNoticeText:(NSString *)txt;
///隐藏提示
- (void)cs_hideNotice;
///设置图片
- (void)cs_setNoticeImg:(UIImageView *)imgView;
///绑定事件block
- (void)cs_addTouchReloadBlock:(ReloadBlock)reloadBlock;

///显示提示 图片和文字
- (void)cs_showNotice:(NSString *)txt
                  img:(UIImage *)img;
- (void)cs_hideNoticeView;

@end
