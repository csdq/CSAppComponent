//
//  CSIndexLetterView.m
//  OA
//
//  Created by mr.s on 16/7/13.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import "CSIndexLetterView.h"
@interface CSIndexLetterView()
{
    UITableView *_tableView;
    CGPoint _currentPoint;
    UIView *_contentView;
}
@end

@implementation CSIndexLetterView
- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
         [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    _currentPoint = [[touches.allObjects firstObject] locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    CGPoint point = [[touches.allObjects firstObject] locationInView:self];
    NSInteger count = MIN(MAX(0,(NSInteger)(point.y / kCS_INDEX_HEIGHT)),_dataArray.count - 1);
    if(self.selectBlock){
        self.selectBlock([_dataArray[count] uppercaseString]);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    CGPoint point = [[touches.allObjects firstObject] locationInView:self];
    NSInteger count  = MIN(MAX(0,(NSInteger)(point.y / kCS_INDEX_HEIGHT)),_dataArray.count - 1);
    self.index = [NSNumber numberWithInteger:count];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    CGPoint point = [[touches.allObjects firstObject] locationInView:self];
    NSInteger count = MIN(MAX(0,(NSInteger)(point.y / kCS_INDEX_HEIGHT)),_dataArray.count - 1);
    self.index = [NSNumber numberWithInteger:count];
}

- (void)setDataArray:(NSArray *)dataArray{
    self.hidden = dataArray==nil||dataArray.count==0;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _dataArray = dataArray;
    __block NSInteger count = 0;
    [_dataArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){0,count * kCS_INDEX_HEIGHT,20,kCS_INDEX_HEIGHT}];
        label.text = [obj uppercaseString];
        label.textColor = self.textColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        count++;
    }];
}

- (UIColor *)textColor{
    if(_textColor == nil){
        _textColor = [UIColor blueColor];
    }
    return _textColor;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
