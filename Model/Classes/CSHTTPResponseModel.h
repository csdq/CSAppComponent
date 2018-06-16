//
//  CSHTTPResponseModel.h
//   CSAppComponent
//
//  Created by temps on 2017/3/19.
//  Copyright © Mr.s. All rights reserved.
//

#import <CSDataModel/CSDataModel.h>
#import "CSHelper.h"
@interface CSHTTPResponseModel : CSBaseModel
//返回结果信息
CS_PROPERTY_STRING(message);
//错误码
CS_PROPERTY_NUMBER(status);
//数据
CS_PROPERTY_ARRAY(datas)
CS_PROPERTY_STRING(action)// = inquireDoctorListVisited;
CS_PROPERTY_STRING(flag)// = SUCCESS;
CS_PROPERTY_STRING(format)// = json;
CS_PROPERTY_NUMBER(pageIndex)// = 4;
CS_PROPERTY_NUMBER(pageSize)// = 20;
CS_PROPERTY_NUMBER(totalPageCount)// = 1;
CS_PROPERTY_NUMBER(totalRecordCount)// = 9;
CS_PROPERTY_STRING(version)// = "v1.0";
@end
