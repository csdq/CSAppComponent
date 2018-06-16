//
//   CSAppComponentSetting.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/26.
//

#import "CSBaseSetting.h"

static CSBaseSettingModel *_settingModel = nil;
static NSBundle * cs_base_res_bundle;
static NSBundle *cs_base_framework_bundle;

@implementation CSBaseSetting
+ (void)moduleInit{
    [self moduleInitWithDict:nil];
}

+ (void)moduleInitWithDict:(NSDictionary *)config{
    if(config){
        _settingModel = [CSBaseSettingModel modelFromDict:config];
    }
}

+ (NSBundle *)cs_base_res_bundle{
    if(!cs_base_res_bundle){
        cs_base_res_bundle = [NSBundle bundleWithPath:[[self cs_base_framework_bundle] pathForResource:@"CSAppComponent" ofType:@"bundle"]];
    }
    return cs_base_res_bundle;
}

+ (NSBundle *)cs_base_framework_bundle{
    if(!cs_base_framework_bundle){
        cs_base_framework_bundle = [NSBundle bundleForClass:[CSBaseSetting class]];
    }
    return cs_base_framework_bundle;
}
//
+ (CSBaseSettingModel *)settingModel{
    if(!_settingModel){
//        默认颜色
        _settingModel = [CSBaseSettingModel new];
    }
    return _settingModel;
}

+ (void)addSetting:(id)obj forKey:(NSString *)key{
    NSAssert(obj,@"obj cannot be nil");
    [[self settingModel].otherSetting setObject:obj forKey:key];
}
@end
