//
//  CSBaseViewModel.m
//  CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSBaseViewModel.h"

@implementation CSBaseViewModel
+ (instancetype)alloc{
    CSBaseViewModel *model = [super alloc];
    [model cs_setViewModel];
    return model;
}

- (void)cs_setViewModel{
    
}
@end
