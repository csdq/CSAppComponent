//
//  CSDashLineView.m
//  CSAppComponent-CSAppComponent
//
//  Created by Mr.s on 2018/10/23.
//

#import "CSDashLineView.h"

@interface CSDashLineHorizontal()
@property (nonatomic,assign) IBInspectable CGFloat dashHeight;
@property (nonatomic,assign) IBInspectable CGFloat dashWidth;
@property (nonatomic,strong) IBInspectable UIColor* dashColor;
@end
IB_DESIGNABLE
@implementation CSDashLineHorizontal
- (void)drawRect:(CGRect)rect {
    if(self.dashHeight == 0){
        self.dashHeight = 1.0f;
    }
    if(self.dashWidth == 0){
        self.dashWidth = 2.0f;
    }
    if(self.dashColor == NULL || [self.dashColor isEqual:[UIColor clearColor]]){
        self.dashColor
        = [UIColor lightGrayColor];
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, self.dashHeight);
    CGContextSetStrokeColorWithColor(context, self.dashColor.CGColor);
    CGFloat lengths[] = {self.dashWidth * 1.5,self.dashWidth};
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0.0);
    CGContextStrokePath(context);
}


@end

@interface CSDashLineVerhical()
@property (nonatomic,assign) IBInspectable CGFloat dashHeight;
@property (nonatomic,assign) IBInspectable CGFloat dashWidth;
@property (nonatomic,strong) IBInspectable UIColor* dashColor;
@end
IB_DESIGNABLE
@implementation CSDashLineVerhical
- (void)drawRect:(CGRect)rect {
    if(self.dashHeight == 0){
        self.dashHeight = 1.0f;
    }
    if(self.dashWidth == 0){
        self.dashWidth = 2.0f;
    }
    if(self.dashColor == NULL || [self.dashColor isEqual:[UIColor clearColor]]){
        self.dashColor
        = [UIColor lightGrayColor];
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, self.dashHeight);
    CGContextSetStrokeColorWithColor(context, self.dashColor.CGColor);
    CGFloat lengths[] = {self.dashWidth * 1.5, self.dashWidth};
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, 0.0,self.frame.size.height);
    CGContextStrokePath(context);
}


@end
