//
//  NavViewController.h
//  CSDQ
//
//  Created by Mr.S on 16/3/7.
//  Copyright © 2016年 CSDQ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ///无效果
    CSNavTransEffectTypeNone,
    ///移动效果
    CSNavTransEffectTypeMove,
    ///缩放效果
    CSNavTransEffectTypeScale,
} CSNavTransEffectType;

@interface CSNavViewController : UINavigationController
@property (assign , nonatomic) BOOL canDragBack;
@property (nonatomic , assign) CSNavTransEffectType effectType;
///delegate will show viewController
- (void)willShow:(UIViewController *)vc;
///delegate did show viewController
- (void)didShow:(UIViewController *)vc;
//
- (void)enableCustomSet;
- (void)disableCustomSet;

@end
