//
//  UIView+CSNotice.h
//  CSAppComponent
//
//  Created by Mr.s on 2018/7/16.
//

#import <UIKit/UIKit.h>

typedef void(^ReloadBlock)(void);
@interface UIView (CSNotice)
///显示提示（如果设置了图片则显示图片和文字）
- (void)cs_showNoticeText:(NSString *)txt;
///隐藏提示
- (void)cs_hideNotice;
///设置图片
- (void)cs_setNoticeImg:(UIImageView *)imgView;
///绑定事件block
- (void)cs_addTouchReloadBlock:(ReloadBlock)reloadBlock;
@end
