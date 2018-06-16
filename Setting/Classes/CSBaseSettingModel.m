//
//  CSBaseSettingModel.m
//  CSAppComponent
//
//  Created by Mr.s on 2017/4/11.
//

#import "CSBaseSettingModel.h"

@implementation CSBaseSettingModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _viewControllerBackgroundColor = [UIColor whiteColor];
        _otherSetting = [NSMutableDictionary dictionary];
    }
    return self;
}

- (UIColor *)themeColor{
    if(!_themeColor){
        return [UIColor whiteColor];
    }
    return _themeColor;
}
@end
