//
//  CSXMLParserDelegate.h
//  OA
//
//  Created by Mr.s on 16/7/21.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CSDataModel/CSDataModel.h>

@interface CSXMLBaseModel : CSBaseModel
//2016-10-26 新添加 针对WebService解析添加的属性 对象内XML对象数组 对应关系：key-value：对象开始标签-模型类型名称
@property (nonatomic , strong) NSDictionary *arrayModelNameDict;
@property (nonatomic , strong) NSMutableArray *subItemArray;
@end


@interface CSResponseStateModel : NSObject
@property (nonatomic , strong) NSString *code;
@property (nonatomic , strong) NSString *info;
@end

typedef void(^CSOAParseFinishBlock)(CSResponseStateModel *state,NSArray *resultArray);

@interface CSXMLParserDelegate : NSObject<NSXMLParserDelegate>
@property (nonatomic , strong , readonly) NSArray *resultArray;
@property (nonatomic , strong , readonly) CSResponseStateModel *stateModel;
@property (nonatomic , strong) CSOAParseFinishBlock finishBlock;
@property (nonatomic , strong) NSString *modelName;
@property (nonatomic , strong) NSString *modelStartTag;
@property (nonatomic , strong) NSString *modelEndTag;
- (instancetype)initWithModelName:(NSString *)modelName
                    modelStartTag:(NSString *)startTag
                      modelEndTag:(NSString *)endTag
                      finishBlock:(CSOAParseFinishBlock)block;
- (instancetype)init NS_UNAVAILABLE;
@end
