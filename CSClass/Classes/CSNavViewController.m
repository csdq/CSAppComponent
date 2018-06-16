//
//  NavViewController.h
//  CSDQ
//
//  Created by Mr.S on 16/3/7.
//  Copyright © 2016年 CSDQ. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#import "CSNavViewController.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat screenWidth ;
@interface CSNavViewController ()<UINavigationControllerDelegate>
{
    CGPoint startTouch;
    UIImageView *lastScreenShootView;
    UIView *blackMask;
    NSInteger viewControllerCount;
    BOOL _isMoving;
    UIScreenEdgePanGestureRecognizer *_mainRecognizer;
}
@property (strong , nonatomic) NSMutableArray *screenShotsList;
@property (strong , nonatomic) UIView *backgroundView;
@end

@implementation CSNavViewController
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self navInit];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self navInit];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self navInit];
    }
    return self;
}

- (void)navInit{
    self.screenShotsList = [NSMutableArray array];
    self.canDragBack = YES;
    self.delegate = self;
    self.effectType = CSNavTransEffectTypeNone;
    screenWidth = [UIScreen mainScreen].bounds.size.width;

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
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (void)enableCustomSet{
    self.delegate = self;
    [self.view addGestureRecognizer:_mainRecognizer];
}

- (void)disableCustomSet{
    [self.screenShotsList removeAllObjects];
    self.delegate = nil;
    [self.view removeGestureRecognizer:_mainRecognizer];
}

- (void)dealloc{
    self.screenShotsList = nil;
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NSBundle *res_bundle =  [NSBundle bundleWithPath:[[NSBundle bundleForClass:[CSNavViewController class]] pathForResource:@"CSBase" ofType:@"bundle"]];
    UIImage *sideImg = [UIImage imageWithContentsOfFile:[res_bundle pathForResource:@"cs_leftside_shadow" ofType:@"png"]];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:sideImg];
    shadowImageView.frame = CGRectMake(-8, 0, 8, self.view.frame.size.height);
    [self.view addSubview:shadowImageView];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    __weak CSNavViewController *bSelf = self;
    [self.view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [bSelf.view removeGestureRecognizer:obj];
    }];
    _mainRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(paningGestureReceive:)];
    _mainRecognizer.edges = UIRectEdgeLeft;
    [_mainRecognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:_mainRecognizer];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    return [super popViewControllerAnimated:animated];
}

#pragma mark - Utility Methods -
- (UIImage *)capture{
    UIImage *img;
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)transViewWithX:(float)x{
    x = x>screenWidth?screenWidth:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    switch (self.effectType) {
        case CSNavTransEffectTypeMove:
        {
            CGSize size = lastScreenShootView.frame.size;
            CGFloat delatX = MIN(size.width,- 0.5 * size.width + x/2.0f);
            lastScreenShootView.frame = (CGRect){delatX,0,lastScreenShootView.frame.size.width,lastScreenShootView.frame.size.height};
            blackMask.alpha = MAX(0.1,0.3 - (x/800.0));
        }
            break;
        case CSNavTransEffectTypeScale:
        {
            float scale = MIN(1.05,(x/6400.0)+0.95);
            float alpha = MAX(0.1,0.3 - (x/800.0));
            lastScreenShootView.transform = CGAffineTransformMakeScale(scale, scale);
            blackMask.alpha = alpha;
        }
            break;
        case CSNavTransEffectTypeNone:
            lastScreenShootView.frame = self.view.bounds;
            blackMask.alpha = 0;
        default:
            break;
    }
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIScreenEdgePanGestureRecognizer *)recoginzer
{
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    __weak CSNavViewController *bSelf = self;
    switch (recoginzer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _isMoving = YES;
            startTouch = touchPoint;
            
            if (!self.backgroundView)
            {
                CGRect frame = self.view.frame;
                
                self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
                [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
                
                blackMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
                blackMask.backgroundColor = [UIColor blackColor];
                [self.backgroundView addSubview:blackMask];
            }
            
            self.backgroundView.hidden = NO;
            
            if (lastScreenShootView) [lastScreenShootView removeFromSuperview];
            
            UIImage *lastScreenShoot = [self.screenShotsList lastObject];
            lastScreenShootView = [[UIImageView alloc] initWithImage:lastScreenShoot];
            [self.backgroundView insertSubview:lastScreenShootView belowSubview:blackMask];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (touchPoint.x - startTouch.x > 80)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    [bSelf transViewWithX:screenWidth];
                } completion:^(BOOL finished) {
                    
                    [bSelf popViewControllerAnimated:NO];
                    CGRect frame = bSelf.view.frame;
                    frame.origin.x = 0;
                    bSelf.view.frame = frame;
                    self->_isMoving = NO;
                }];
            }
            else
            {
                [UIView animateWithDuration:0.3 animations:^{
                    [bSelf transViewWithX:0];
                } completion:^(BOOL finished) {
                    self->_isMoving = NO;
                    bSelf.backgroundView.hidden = YES;
                }];
                
            }
            return;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [UIView animateWithDuration:0.3 animations:^{
                [bSelf transViewWithX:0];
            } completion:^(BOOL finished) {
                self->_isMoving = NO;
                bSelf.backgroundView.hidden = YES;
            }];
            
            return;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (_isMoving) {
                [bSelf transViewWithX:touchPoint.x - startTouch.x];
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(viewControllerCount > self.viewControllers.count){
        for (int i = 0; i < viewControllerCount - self.viewControllers.count; ++i) {
            [self.screenShotsList removeObjectAtIndex:viewControllerCount - i - 1];
        }
        viewControllerCount = self.viewControllers.count;
    }
    [self didShow:viewController];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(viewControllerCount < self.viewControllers.count){
        [self.screenShotsList addObject:[self capture]];
        viewControllerCount = self.viewControllers.count;
    }
    [self willShow:viewController];
}

- (void)willShow:(UIViewController *)vc{
    
}

- (void)didShow:(UIViewController *)vc{
    
}
@end
