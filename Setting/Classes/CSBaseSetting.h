//
//   CSAppComponentSetting.h
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CSBaseSettingModel.h"
@protocol CSModuleManagerProtocol<NSObject>
@required
//AppDelegate 中需要调用
+ (void)moduleInit;
+ (void)moduleInitWithDict:(NSDictionary *)config;
@end

@interface CSBaseSetting : NSObject<CSModuleManagerProtocol>
+ (NSBundle *)cs_base_res_bundle;
+ (NSBundle *)cs_base_framework_bundle;
//
+ (CSBaseSettingModel *)settingModel;
///添加设置到setting Model
+ (void)addSetting:(id)obj forKey:(NSString *)key;
@end
