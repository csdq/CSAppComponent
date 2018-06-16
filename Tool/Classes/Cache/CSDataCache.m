//
//  CSDataCache.m
//  CSAppComponent
//
//  Created by Mr.s on 2017/5/9.
//  Copyright © 2017年 Mr.s. All rights reserved.
//

#import "CSDataCache.h"
static CSDataCache *_cache;

@interface CSDataCache()
@property (nonatomic,strong) NSMutableDictionary * mDict;

@end

@implementation CSDataCache
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [CSDataCache new];
    });
    return _cache;
}

+ (void)setCache:(id)obj for:(NSString *)key{
    if(obj == nil){
        [[CSDataCache shared].mDict removeObjectForKey:key];
    }else{
        [[CSDataCache shared].mDict setObject:obj forKey:key];
    }
}

+ (id)getCacheFor:(NSString *)key{
    return [[CSDataCache shared].mDict objectForKey:key];
}

- (NSMutableDictionary *)mDict{
    if(!_mDict){
        _mDict = [NSMutableDictionary dictionary];
    }
    return _mDict;
}
@end
