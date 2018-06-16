//
//  CSBaseSettingModel.h
//  CSAppComponent
//
//  Created by Mr.s on 2017/4/11.
//

#import <CSDataModel/CSDataModel.h>

@interface CSBaseSettingModel : CSBaseModel
///主题色
@property (nonatomic,strong) UIColor *themeColor;
///视图控制器背景色
@property (nonatomic,strong) UIColor *viewControllerBackgroundColor;
@property (nonatomic,strong) NSString * baseURL;
//v1.0版本接口地址
@property (nonatomic,strong) NSString * API_v1_URL;
@property (nonatomic,strong) NSString * File_Download_URL;
@property (nonatomic,strong) NSString * File_Upload_URL;
//....待扩展

//其他配置
@property (nonatomic,strong) NSMutableDictionary *otherSetting;

@end
