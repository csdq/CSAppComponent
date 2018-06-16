//
//  UIView+CSCustom.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/18.
//

#import "UIView+CSCustom.h"
#import <objc/runtime.h>

@implementation UIView (CSCustom)
+ (void)load{
    //
    SEL alloc = @selector(alloc);
    SEL cs_alloc = @selector(_cs_alloc);
    Method allocMethod = class_getInstanceMethod(self.class, alloc);
    Method newAllocMethod = class_getInstanceMethod(self.class, cs_alloc);
    method_exchangeImplementations(allocMethod, newAllocMethod);
}

+ (instancetype)_cs_alloc{
    UIView *view = [self _cs_alloc];
    [view afterInit];
    return view;
}

- (void)afterInit{
    
}
@end
