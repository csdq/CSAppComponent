//
//  CSTextLayer.m
//  OAVendors
//
//  Created by stq on 16/9/27.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import "CSTextLayer.h"

@implementation CSTextLayer
- (void)drawInContext:(CGContextRef)ctx{
    CGFloat height = self.bounds.size.height;
    CGFloat fontSize = self.fontSize;
    CGFloat yDelta = (height - fontSize)/2 - fontSize / 12;
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0.0, yDelta);
    [super drawInContext:ctx];
    CGContextRestoreGState(ctx);
}

@end
