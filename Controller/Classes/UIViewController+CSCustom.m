//
//  UIViewController+CSCustom.m
//   CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import "UIViewController+CSCustom.h"
#import "CSBaseSetting.h"
#import <objc/runtime.h>
#import <Masonry/Masonry.h>
#import "CSBaseNavViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static char const * kCS_SPIN_VIEW_KEY = "kCS_SPIN_VIEW_KEY";
@implementation UIViewController (CSCustom)
@dynamic spinView;

+ (void)load{
    //viewDidLoad
    SEL viewDidLoad = @selector(viewDidLoad);
    SEL newViewDidLoad = @selector(_cs_viewDidLoad);
    Method viewDidLoadMethod = class_getInstanceMethod(self.class, viewDidLoad);
    Method newViewDidLoadMethod = class_getInstanceMethod(self.class, newViewDidLoad);
    method_exchangeImplementations(viewDidLoadMethod, newViewDidLoadMethod);
    //viewWillAppear:
    SEL viewWillAppear = @selector(viewWillAppear:);
    SEL newViewWillAppear = @selector(_cs_viewWillAppear:);
    Method viewWillAppearMethod = class_getInstanceMethod(self.class, viewWillAppear);
    Method newViewWillAppearMethod = class_getInstanceMethod(self.class, newViewWillAppear);
    method_exchangeImplementations(viewWillAppearMethod, newViewWillAppearMethod);
}

- (void)_cs_viewDidLoad{
    @weakify(self)
    [[RACObserve(self, title) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        if([x isKindOfClass:[NSString class]]){
            self.cs_navigationBar.title = x;
        }
    }];
    [self _cs_viewDidLoad];
    [self cs_viewDidLoad];
    [self cs_setModel];
    [self cs_setViewModel];
    [self cs_setView];
    if([self respondsToSelector:@selector(requestNewData)]){
        [self requestNewData];
    }
}

- (void)_cs_viewWillAppear:(BOOL)animated{
    [self _cs_viewWillAppear:animated];
    [self cs_viewWillAppear:animated];
    if(
       //保证上级是 naviagtionController
       (self.navigationController && [self.parentViewController isEqual:self.navigationController])
       &&
       //是自定义的CSNavViewController 并且使用自定义导航栏
       ([self.navigationController isKindOfClass:[CSNavViewController class]]
       && ((CSBaseNavViewController *)self.navigationController).useCustomNavigationBar)
       ){
        //自定义NavController
        //插入到第一级
        if(self.cs_navigationBar.superview == nil){
            [self.view insertSubview:self.cs_navigationBar atIndex:self.view.subviews.count];
        }else{
            
        }
        [self.cs_navigationBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            if(@available(iOS 11,*)){
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.height.equalTo(@(44));
            }else{
                make.top.equalTo(self.mas_topLayoutGuide);
                make.left.equalTo(self.view.mas_left);
                make.right.equalTo(self.view.mas_right);
                make.height.equalTo(@(44));
            }
        }];
        if(@available(iOS 11, *)){
            self.additionalSafeAreaInsets = UIEdgeInsetsMake(44, 0, 0, 0);
        }
    }
}

//设置视图
- (void)cs_setView{
    
}
//设置数据模型／容器
- (void)cs_setModel{
    
}
//设置视图模型
- (void)cs_setViewModel{
    
}

- (void)cs_viewDidLoad {
    //
}


- (void)cs_viewWillAppear:(BOOL)animated {
    //
}

- (UIActivityIndicatorView *)spinView{
    UIActivityIndicatorView *spin = objc_getAssociatedObject(self, kCS_SPIN_VIEW_KEY);
    if(spin){
        return spin;
    }
    spin = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    spin.color = [CSBaseSetting settingModel].themeColor;
    spin.hidesWhenStopped = YES;
    objc_setAssociatedObject(self, kCS_SPIN_VIEW_KEY, spin, OBJC_ASSOCIATION_RETAIN);
    @weakify(self)
    [self.rac_willDeallocSignal subscribeCompleted:^{
        @strongify(self)
        objc_removeAssociatedObjects(self);
    }];
    return spin;
}
//MARK: --
//MARK: 显示“菊花”
- (void)showLoadState{
    UIActivityIndicatorView *spin = self.spinView;
    if(spin.superview == nil){
        [self.view addSubview:spin];
        CGSize size = [UIScreen mainScreen].bounds.size;
        spin.center = CGPointMake(size.width / 2.0f, size.height / 2.6f);
    }
    [self.view bringSubviewToFront:spin];
    [spin startAnimating];
}
//MARK: 隐藏“菊花”
- (void)hideLoadState{
    if(self.spinView.superview){
        [self.spinView stopAnimating];
    }
}

- (void)gestureBackEnable:(BOOL)yesOrNo{
    if((self.navigationController && [self.parentViewController isEqual:self.navigationController])
        && [self.navigationController isKindOfClass:[CSNavViewController class]]){
        UIScreenEdgePanGestureRecognizer *ges = [self.navigationController valueForKey:@"_mainRecognizer"];
        if([ges isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]){
            ges.enabled = yesOrNo;
        }
    }
}
@end
