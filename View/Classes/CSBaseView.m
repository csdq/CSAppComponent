//
//  CSBaseView.m
//  CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSBaseView.h"

@implementation CSBaseView
- (instancetype)initWithViewModel:(CSBaseViewModel *)model
{
    self = [super init];
    if (self) {
        _viewModel = model;
        [self cs_setView];
    }
    return self;
}

- (void)cs_setView{
    self.backgroundColor = [UIColor whiteColor];
}

@end
