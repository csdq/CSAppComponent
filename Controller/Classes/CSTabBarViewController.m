//
//  CSTabBarViewController.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/18.
//

#import "CSTabBarViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIViewController+CSCustom.h"
@interface CSTabBarViewController ()<UITabBarControllerDelegate>

@end

@implementation CSTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    [super setSelectedIndex:selectedIndex];
    if(self.childViewControllers.count > selectedIndex){
        UIViewController *viewController = self.childViewControllers[selectedIndex];
        if(viewController.cs_navigationBar && viewController.cs_navigationBar.titleView){
            self.cs_navigationBar.titleView = viewController.cs_navigationBar.titleView;
        }else{
            self.cs_navigationBar.title = viewController.title;
        }
        self.cs_navigationBar.rightView = viewController.cs_navigationBar.rightView;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//MARK: delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if(viewController.cs_navigationBar && viewController.cs_navigationBar.titleView){
        self.cs_navigationBar.titleView = viewController.cs_navigationBar.titleView;
    }else{
        self.cs_navigationBar.title = viewController.title;
    }
    self.cs_navigationBar.rightView = viewController.cs_navigationBar.rightView;
}

@end
