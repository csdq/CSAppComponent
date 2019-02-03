//
//  UIViewController+CSNavigationBar.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/11.
//

#import "UIViewController+CSNavigationBar.h"
#import <objc/runtime.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

const char * CS_Nav_Bar_Key = "CS_Nav_Bar_Key";
@implementation UIViewController (CSNavigationBar)
@dynamic cs_navigationBar;
- (CSNavigationBar *)cs_navigationBar{
    id obj = objc_getAssociatedObject(self, CS_Nav_Bar_Key);
    if([obj isKindOfClass:[UINavigationBar class]]){
        return obj;
    }else{
        @weakify(self)
        CSNavigationBar * navBar = [CSNavigationBar navigationBar];
        if(![self hideBackButton]){
            ///返回按钮显示 并且绑定事件
            navBar.backBtn.hidden = NO;
        }
        [navBar.backBtnTouchInsideSubject subscribeNext:^(id x) {
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        }];
        objc_setAssociatedObject(self, CS_Nav_Bar_Key, navBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.rac_willDeallocSignal subscribeCompleted:^{
            @strongify(self)
            objc_removeAssociatedObjects(self);
        }];
        return navBar;
    }
}

- (void)setCustomNavigationBar:(UINavigationBar *)navBar{
    @weakify(self)
    CSNavigationBar * bar = self.cs_navigationBar;
    if(bar.superview){
        [bar removeFromSuperview];
    }
    objc_setAssociatedObject(self, CS_Nav_Bar_Key, navBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        @strongify(self)
        objc_removeAssociatedObjects(self);
    }];
}

- (BOOL)hideBackButton{
    return (!self.navigationController)
    ||[self.navigationController.viewControllers indexOfObject:self] == 0
    ||(self.parentViewController
       && (![self.parentViewController isKindOfClass:[UINavigationController class]]
           && [self.navigationController.viewControllers indexOfObject:self.parentViewController]==0));
}
@end
