//
//  CSXMLParserDelegate.m
//  OA
//
//  Created by Mr.s on 16/7/21.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import "CSXMLParserDelegate.h"
#import <objc/runtime.h>

@implementation CSXMLResponseStateModel
@end
@implementation CSXMLBaseModel
@end

@interface CSXMLParserDelegate()
{
    Ivar *ivarList;
    unsigned int count;
}
@property (nonatomic , strong) NSMutableString *dataString;
@property (nonatomic , strong) NSMutableArray *elementArray;
@property (nonatomic , strong) NSMutableArray *result;
@property (nonatomic , strong) CSXMLBaseModel *model;
@property (nonatomic , strong) CSXMLBaseModel *subModel;
@property (nonatomic , strong) NSString *subModelEndTag;
@end
@implementation CSXMLParserDelegate
@synthesize resultArray = _resultArray;

- (instancetype)initWithModelName:(NSString *)modelName
                    modelStartTag:(NSString *)startTag
                      modelEndTag:(NSString *)endTag
                      finishBlock:(CSOAParseFinishBlock)block{
    self = [super init];
    if (self) {
        self.modelName = modelName;
        self.modelStartTag = startTag;
        self.modelEndTag = endTag;
        self.finishBlock = block;
    }
    return self;
}

- (void)dealloc
{
    ivarList = NULL;
}
#pragma mark - NSXMLParserDelegate Methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"parse begin");
    self.result = [NSMutableArray array];
    self.elementArray = [NSMutableArray array];
    self.dataString = [NSMutableString string];
    ivarList = class_copyIvarList(NSClassFromString(_modelName), &count);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    _resultArray = [self.result copy];
    if(_finishBlock){
        _finishBlock(_stateModel,_resultArray);
    }
    NSLog(@"parse end:\n Data Count:\n-->>%ld<<<--\n",(unsigned long)_resultArray.count);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    [self.elementArray addObject:elementName];
    [self.dataString setString:@""];
    if([elementName isEqualToString:self.modelStartTag]){
        self.model = [NSClassFromString(_modelName) new];
        return;
    }
    if([self.model isKindOfClass:[CSXMLBaseModel class]]){
        NSDictionary *subDict = self.model.arrayModelNameDict[elementName];
        if(subDict!=nil && [elementName isEqualToString:subDict[@"begin"]]){
            //创建一个字对象 并存到数组内
            self.subModelEndTag = subDict[@"end"];
            self.subModel = [NSClassFromString(subDict[@"model"]) new];
            return;
        }
    }
    if([elementName isEqualToString:@"ret_code"]){
        _stateModel = [CSXMLResponseStateModel new];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    NSString *lastElement = [self.elementArray lastObject];
    if([lastElement isEqualToString:elementName]){
        if([lastElement isEqualToString:@"ret_code"]){
            _stateModel.code = [self.dataString copy];
        }else if([lastElement isEqualToString:@"ret_info"]){
            _stateModel.info = [self.dataString copy];
        }else if(self.subModel!=nil){
            unsigned int subCount = 0;
            Ivar * subIvarList = class_copyIvarList([self.subModel class], &subCount);
            
            const char * element = [[@"_" stringByAppendingString:lastElement] UTF8String];
            for (int i=0; i<subCount; i++) {
                if(0 == strcmp(ivar_getName(subIvarList[i]),element)){
                    object_setIvar(_subModel, subIvarList[i], [self.dataString copy]);
                    break;
                }
            }
            if(self.subModel!=nil && [self.subModelEndTag isEqualToString:elementName]){
                self.subModelEndTag = nil;
                [_subModel didSetPropertyValue];
                [self.model.subItemArray addObject:[_subModel copy]];
                _subModel = nil;
            }

        }else{
            const char * element = [[@"_" stringByAppendingString:lastElement] UTF8String];
            for (int i=0; i<count; i++) {
                if(0 == strcmp(ivar_getName(ivarList[i]),element)){
                    object_setIvar(_model, ivarList[i], [self.dataString copy]);
                    break;
                }
            }
            if(_model!=nil && [elementName isEqualToString:self.modelEndTag]){
                __typeof(self.model) obj = [_model copy];
                obj.subItemArray = [_model.subItemArray copy];
                [obj didSetPropertyValue];
                [self.result addObject:obj];
                _model = nil;
            }
        }
    }
    
    [self.dataString setString:@""];
    [self.elementArray removeLastObject];
}
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
   /* if([string isEqualToString:@"\n"] || [[[string stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] length]==0){
        return;
    }else{
        [self.dataString appendString:string];
    }
    */
     [self.dataString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    if(_finishBlock){
        _stateModel = [CSXMLResponseStateModel new];
        _stateModel.code = @"-1";
        _stateModel.info = [NSString stringWithFormat:@"解析错误:%@",parseError.localizedDescription];
        _finishBlock(_stateModel,_resultArray);
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    if(_finishBlock){
        _stateModel = [CSXMLResponseStateModel new];
        _stateModel.code = @"-1";
        _stateModel.info = [NSString stringWithFormat:@"验证错误:%@",validationError.localizedDescription];
        _finishBlock(_stateModel,_resultArray);
    }
}

@end
