//
//  CSIndexLetterView.h
//  OA
//
//  Created by mr.s on 16/7/13.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCS_INDEX_HEIGHT 15.0f

typedef void(^CSSelectLetterBlock)(NSString *letter);
@interface CSIndexLetterView : UIView
@property (nonatomic , strong) NSArray *dataArray;
@property (nonatomic , strong) NSNumber* index;
@property (nonatomic,strong) UIColor * textColor;
@property (nonatomic,copy) CSSelectLetterBlock selectBlock;
@end
