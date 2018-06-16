//
//  CSNavigationBar.h
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/11.
//

#import <UIKit/UIKit.h>
@class RACSubject;
@interface CSNavigationBar : UINavigationBar
///左边按钮
@property (nonatomic,strong) UIButton * backBtn;
@property (nonatomic,strong) RACSubject * backBtnTouchInsideSubject;
///标题
@property (nonatomic,strong) NSString * title;
///动态添加标题视图
@property (nonatomic,strong) UIView * titleView;
@property (nonatomic,strong) UIView * leftView;
@property (nonatomic,strong) UIView * rightView;
///获取实例
+ (instancetype)navigationBar;
///设置导航栏背景图alpha值
- (void)changeBackgroundAlpha:(CGFloat)alpha;
///设置返回按钮标题
- (void)setBackBtnTitle:(NSString *)title;
@end
