//
//  CSHTTPCommonResponseModel.h
//  ReactiveCocoa
//
//  Created by Mr.s on 2017/3/30.
//

#import <CSDataModel/CSDataModel.h>

@interface CSHTTPCommonResponseModel : CSBaseModel
///是否成功
@property (nonatomic,assign) BOOL iSuccess;
@property (nonatomic,assign,nullable) NSHTTPURLResponse *response;
@property (nonatomic,strong,nullable) NSError * error;
//上传/下砸文件进度
@property (nonatomic,strong,nullable) NSProgress * progress;
@property (nonatomic,strong) NSURLSessionDataTask * _Nullable task;
@property (nonatomic,strong) id _Nullable responseObject;

@end
