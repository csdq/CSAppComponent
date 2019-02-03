//
//  CSFlowlayoutView.m
//  CSAppComponent
//
//  Created by Mr.s on 2019/1/31.
//

#import "CSFlowlayoutView.h"
@interface CSFlowlayoutViewFrameInfo : NSObject
//
@property (nonatomic,assign) CGRect frame;
@property (nonatomic,assign) CGFloat nextRowY;
@property (nonatomic,assign) CGFloat nextColumnX;
//
@property (nonatomic,strong) UIView<CSFlowlayoutSubviewProtocol> * view;
//
@property (nonatomic,weak) CSFlowlayoutViewFrameInfo * last;
@property (nonatomic,weak) CSFlowlayoutViewFrameInfo * next;
//
@property (nonatomic,assign) NSInteger row;
@property (nonatomic,assign) NSInteger column;
@end

@implementation CSFlowlayoutViewFrameInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.row = 0;
        self.column = 0;
        self.nextRowY = 0;
        self.nextColumnX = 0;
        self.frame = CGRectZero;
    }
    return self;
}
@end

@interface CSFlowlayoutView()
{
    CGFloat _cs_viewWidth;
    CGFloat _cs_viewHeight;
}
@property (nonatomic,assign) UIInterfaceOrientation orientation;
//
@property (nonatomic,strong) NSMutableArray<CSFlowlayoutViewFrameInfo *> * subviewFrameInfoArray;
//
@property (nonatomic,strong) NSMutableArray<UIView<CSFlowlayoutSubviewProtocol> *> * flowlayoutSubviews;
@end

@implementation CSFlowlayoutView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
        self.viewHeight = CGRectGetHeight(UIScreen.mainScreen.bounds);
        [self _cs_viewSettingInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewWidth = CGRectGetWidth(frame)>0?CGRectGetWidth(frame):CGRectGetWidth(UIScreen.mainScreen.bounds);
        self.viewHeight = CGRectGetHeight(frame)>0?CGRectGetHeight(frame):CGRectGetHeight(UIScreen.mainScreen.bounds);
        [self _cs_viewSettingInit];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.viewWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
    self.viewHeight = CGRectGetHeight(UIScreen.mainScreen.bounds);
    [self _cs_viewSettingInit];
}
//
- (void)_cs_viewSettingInit{
    self.direction = CSFlowlayoutViewVertical;
    self.alwaysBounceVertical = NO;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_cs_rotateSubviews:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_cs_rotateSubviews:(NSNotification *)noti{
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    if(orientation == UIInterfaceOrientationUnknown){
        orientation = UIInterfaceOrientationPortrait;
    }
    if(orientation != self.orientation){
        self.orientation = orientation;
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                _viewHeight = _cs_viewHeight;
                _viewWidth = _cs_viewWidth;
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
            {
                _viewHeight = _cs_viewWidth;
                _viewWidth = _cs_viewHeight;
            }
                break;
            case UIInterfaceOrientationUnknown:
            default:
            {
                
            }
                break;
        }
        [self cs_resetSubviewFrames];
    }
}
//MARK:Public
- (void)cs_addFlowlayoutSubView:(UIView<CSFlowlayoutSubviewProtocol> *)view{
    //
    [self addSubview:view];
    [self.flowlayoutSubviews addObject:view];
    //
    CSFlowlayoutViewFrameInfo * frameInfo = [CSFlowlayoutViewFrameInfo new];
    frameInfo.view = view;
    frameInfo.nextRowY = self.defaultMarginLeft;
    frameInfo.nextColumnX = self.defaultMarginTop;
    //
    CSFlowlayoutViewFrameInfo * lastFrameInfo = self.subviewFrameInfoArray.lastObject;
    if(lastFrameInfo){
        //link
        self.subviewFrameInfoArray.lastObject.next = frameInfo;
        frameInfo.last = lastFrameInfo;
        frameInfo.row = lastFrameInfo.row;
        frameInfo.column = lastFrameInfo.column;
    }
    [self.subviewFrameInfoArray addObject:frameInfo];
    [self _cs_setFrameWith:frameInfo];
}

- (void)cs_removeFlowlayoutSubView:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view{
    if(view){
        if([self.flowlayoutSubviews containsObject:view]){
            @synchronized (self) {
                NSInteger idx = [self.flowlayoutSubviews indexOfObject:view];
                CSFlowlayoutViewFrameInfo * current = self.subviewFrameInfoArray[idx];
                CSFlowlayoutViewFrameInfo * last = current.last;
                CSFlowlayoutViewFrameInfo * next = current.next;
                last.next = next;
                next.last = last;
                [self.flowlayoutSubviews removeObject:view];
                [self.subviewFrameInfoArray removeObjectAtIndex:idx];
                [view removeFromSuperview];
                [UIView animateWithDuration:0.3 animations:^{
                    CSFlowlayoutViewFrameInfo * frameInfo = next;
                    while (frameInfo != nil) {
                        [self _cs_setFrameWith:frameInfo];
                        frameInfo = frameInfo.next;
                    }
                }];
            }
        }
    }
}

- (void)cs_updateFlowlayoutSubview:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view{
    if(view){
        if([self.flowlayoutSubviews containsObject:view]){
            NSInteger idx = [self.flowlayoutSubviews indexOfObject:view];
            @synchronized (self) {
                [UIView animateWithDuration:0.3 animations:^{
                    CSFlowlayoutViewFrameInfo * frameInfo = self.subviewFrameInfoArray[idx];
                    while (frameInfo != nil) {
                        [self _cs_setFrameWith:frameInfo];
                        frameInfo = frameInfo.next;
                    }
                }];
            }
        }
    }
}

- (void)cs_clearFlowlayoutSubview{
    @synchronized (self) {
        [self.flowlayoutSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.flowlayoutSubviews removeAllObjects];
        [self.subviewFrameInfoArray removeAllObjects];
    }
}

- (void)cs_resetSubviewFrames{
    @synchronized (self) {
        [UIView animateWithDuration:0.3 animations:^{
            CSFlowlayoutViewFrameInfo * frameInfo = self.subviewFrameInfoArray.firstObject;
            while (frameInfo != nil) {
                [self _cs_setFrameWith:frameInfo];
                frameInfo = frameInfo.next;
            }
        }];
    }
}

- (NSInteger)cs_rowForView:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view{
    if(view){
        if([self.flowlayoutSubviews containsObject:view]){
            CSFlowlayoutViewFrameInfo * frameInfo = self.subviewFrameInfoArray[[self.flowlayoutSubviews indexOfObject:view]];
            return frameInfo.row;
        }
    }
    return -1;
}

- (NSInteger)cs_columnForView:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view{
    if(view){
        if([self.flowlayoutSubviews containsObject:view]){
            CSFlowlayoutViewFrameInfo * frameInfo = self.subviewFrameInfoArray[[self.flowlayoutSubviews indexOfObject:view]];
            return frameInfo.column;
        }
    }
    return -1;
}

//MARK:
- (void)_cs_setFrameWith:(CSFlowlayoutViewFrameInfo *)frameInfo{
    if(frameInfo){
        @synchronized (self) {
            CSFlowlayoutViewFrameInfo * lastFrameInfo = frameInfo.last;
            //Size
            CGFloat width = CGRectGetWidth(frameInfo.view.frame);
            CGFloat height = CGRectGetHeight(frameInfo.view.frame);
            if([frameInfo.view respondsToSelector:@selector(cs_viewWidth)]){
                width = frameInfo.view.cs_viewWidth;
            }
            if([frameInfo.view respondsToSelector:@selector(cs_viewHeight)]){
                height = frameInfo.view.cs_viewHeight;
            }
            //Calculate
            if(self.direction == CSFlowlayoutViewVertical){
                //宽度超限
                if(width>self.viewWidth){
                    if(nil == lastFrameInfo){
                        //第一个
                        frameInfo.row = 0;
                        frameInfo.column = 0;
                        frameInfo.frame = CGRectMake(self.defaultMarginLeft, self.defaultMarginTop, width, height);
                    }else{
                        frameInfo.row = lastFrameInfo.row+1;
                        frameInfo.column = 0;
                        frameInfo.frame = CGRectMake(self.defaultMarginLeft, lastFrameInfo.nextRowY, width, height);
                    }
                }else{
                    if(nil == lastFrameInfo){
                        //第一个
                        frameInfo.row = 0;
                        frameInfo.column = 0;
                        frameInfo.frame = CGRectMake(self.defaultMarginLeft, self.defaultMarginTop, width, height);
                    }else{
                        if((lastFrameInfo.nextColumnX + width) > self.viewWidth){
                            //new line
                            frameInfo.row = lastFrameInfo.row+1;
                            frameInfo.column = 0;
                            frameInfo.frame = CGRectMake(self.defaultMarginLeft, lastFrameInfo.nextRowY, width, height);
                            frameInfo.nextRowY = CGRectGetMaxY(frameInfo.frame) + self.rowMargin;
                        }else{
                            //
                            frameInfo.row = lastFrameInfo.row;
                            frameInfo.column = lastFrameInfo.column+1;
                            frameInfo.frame = CGRectMake(lastFrameInfo.nextColumnX, CGRectGetMinY(lastFrameInfo.frame), width, height);
                        }
                    }
                }
                if(lastFrameInfo){
                    frameInfo.nextRowY = MAX(lastFrameInfo.nextRowY, CGRectGetMaxY(frameInfo.frame)+self.rowMargin);
                    frameInfo.nextColumnX = CGRectGetMaxX(frameInfo.frame) + self.colMargin;
                }else{
                    frameInfo.nextRowY = CGRectGetMaxY(frameInfo.frame)+self.rowMargin;
                    frameInfo.nextColumnX = CGRectGetMaxX(frameInfo.frame) + self.colMargin;
                }
                
            }else{
                //高度超限
                if(height>self.viewHeight){
                    if(frameInfo.row != 0){
                        //换列
                        frameInfo.column = frameInfo.column+1;
                        frameInfo.row = 0;
                    }
                    if(nil == lastFrameInfo){
                        //第一个
                        frameInfo.frame = CGRectMake(self.defaultMarginLeft, self.defaultMarginTop, width, height);
                    }else{
                        frameInfo.frame = CGRectMake(lastFrameInfo.nextColumnX,self.defaultMarginTop, width, height);
                    }
                }else{
                    if(nil == lastFrameInfo){
                        //第一个
                        lastFrameInfo.column = 0;
                        frameInfo.frame = CGRectMake(self.defaultMarginLeft, self.defaultMarginTop, width, height);
                    }else{
                        if((lastFrameInfo.nextRowY + height) > self.viewHeight){
                            //new line
                            frameInfo.column = lastFrameInfo.column+1;
                            frameInfo.row = 0;
                            frameInfo.frame = CGRectMake(lastFrameInfo.nextColumnX,self.defaultMarginTop, width, height);
                            frameInfo.nextColumnX = CGRectGetMaxX(frameInfo.frame) + self.colMargin;
                        }else{
                            //
                            frameInfo.column = lastFrameInfo.column;
                            frameInfo.row = lastFrameInfo.row+1;
                            frameInfo.frame = CGRectMake(CGRectGetMinX(lastFrameInfo.frame), lastFrameInfo.nextRowY, width, height);
                        }
                    }
                }
                if(lastFrameInfo){
                    frameInfo.nextColumnX = MAX(lastFrameInfo.nextColumnX, CGRectGetMaxX(frameInfo.frame)+self.rowMargin);
                    frameInfo.nextRowY = CGRectGetMaxY(frameInfo.frame) + self.rowMargin;
                }else{
                    frameInfo.nextColumnX = CGRectGetMaxX(frameInfo.frame) + self.colMargin;
                    frameInfo.nextRowY = CGRectGetMaxY(frameInfo.frame)+self.rowMargin;
                }
            }
            frameInfo.view.frame = frameInfo.frame;
            if(self.direction == CSFlowlayoutViewVertical){
                self.contentSize = CGSizeMake(self.viewWidth, frameInfo.nextRowY);
            }else{
                self.contentSize = CGSizeMake(frameInfo.nextColumnX,self.viewHeight);
            }
        }
    }else{
        [self cs_clearFlowlayoutSubview];
    }
}
//MARK: Private
- (void)setDefaultMarginLeft:(CGFloat)defaultMarginLeft{
    _defaultMarginLeft = defaultMarginLeft;
}

- (void)setDefaultMarginTop:(CGFloat)defaultMarginTop{
    _defaultMarginTop = defaultMarginTop;
}

- (NSMutableArray<UIView<CSFlowlayoutSubviewProtocol> *> *)flowlayoutSubviews{
    if(!_flowlayoutSubviews){
        _flowlayoutSubviews = [NSMutableArray array];
    }
    return _flowlayoutSubviews;
}

- (NSMutableArray<CSFlowlayoutViewFrameInfo *> *)subviewFrameInfoArray{
    if(!_subviewFrameInfoArray){
        _subviewFrameInfoArray = [NSMutableArray array];
    }
    return _subviewFrameInfoArray;
}

- (void)setViewWidth:(CGFloat)viewWidth{
    _viewWidth = viewWidth;
    _cs_viewWidth = viewWidth;
}

- (void)setViewHeight:(CGFloat)viewHeight{
    _viewHeight = viewHeight;
    _cs_viewHeight = viewHeight;
}
@end

