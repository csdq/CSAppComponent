//
//  CSDataCache.h
//  CSAppComponent
//
//  Created by Mr.s on 2017/5/9.
//  Copyright © 2017年 Mr.s. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDataCache : NSObject
+ (instancetype)shared;
+ (void)setCache:(id)obj for:(NSString *)key;
+ (id)getCacheFor:(NSString *)key;
@end
