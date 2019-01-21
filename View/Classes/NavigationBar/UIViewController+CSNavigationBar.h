//
//  UIViewController+CSNavigationBar.h
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/11.
//

#import <UIKit/UIKit.h>
#import "CSNavigationBar.h"

@interface UIViewController (CSNavigationBar)
///自定义导航栏
@property (nonatomic,strong,readonly) CSNavigationBar * cs_navigationBar;
//
- (void)setCustomNavigationBar:(UINavigationBar *)navBar;
@end
