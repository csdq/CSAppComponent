//
//   CSBaseView.h
//   CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSHelper.h"
#import "CSBaseViewModel.h"
@interface CSBaseView : UIView
@property (nonatomic,strong) CSBaseViewModel *viewModel;
@property (nonatomic,assign) BOOL isViewActive;
- (instancetype)initWithViewModel:(CSBaseViewModel *)model;
- (instancetype)init NS_UNAVAILABLE;
- (void)cs_setView;
@end
