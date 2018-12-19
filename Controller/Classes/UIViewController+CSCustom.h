//
//  UIViewController+CSCustom.h
//   CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSNavViewController.h"
#import "CSNavigationBar.h"
#import "UIViewController+CSNavigationBar.h"

@protocol CSBaseViewControllerProtocol

///系统viewDidLoad后调用
- (void)cs_viewDidLoad;
///系统viewWillAppear调用
- (void)cs_viewWillAppear:(BOOL)animated;
///设置视图 此方法自动调用
- (void)cs_setView;
///设置数据模型／容器 此方法自动调用
- (void)cs_setModel;
///设置视图模型 自动调用
- (void)cs_setViewModel;
/*!@description 显示导航栏/navgationControl push后默认自动显示导航栏*/
- (void)cs_showNavBar;

@optional
///如果定义了该方法 viewdidload时自动调用
- (void)requestNewData;

@end


@interface UIViewController (CSCustom)<CSBaseViewControllerProtocol>
@property (nonatomic,strong,readonly) UIActivityIndicatorView * spinView;
///取消或使用右滑返回上一级
- (void)gestureBackEnable:(BOOL)yesOrNo;
///显示 加载状态
- (void)showLoadState;
///隐藏 加载状态
- (void)hideLoadState;
@end
