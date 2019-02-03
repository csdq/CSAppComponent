//
//  CSFlowlayoutView.h
//  CSAppComponent
//
//  Created by Mr.s on 2019/1/31.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    CSFlowlayoutViewVertical = 0,//default
    CSFlowlayoutViewHorizontal
} CSFlowlayoutViewDirection;

@protocol CSFlowlayoutSubviewProtocol <NSObject>
@optional
//default view.frame.size.width
- (CGFloat)cs_viewWidth;
//default view.frame.size.height
- (CGFloat)cs_viewHeight;
@end

NS_ASSUME_NONNULL_BEGIN
@interface CSFlowlayoutView : UIScrollView
//scrollView 内容延伸方向
@property (nonatomic,assign) CSFlowlayoutViewDirection direction;//default vertical
//
@property (nonatomic,assign) CGFloat viewWidth;
@property (nonatomic,assign) CGFloat viewHeight;
//
@property (nonatomic,assign) CGFloat colMargin;
@property (nonatomic,assign) CGFloat rowMargin;
//
@property (nonatomic,assign) CGFloat defaultMarginLeft;
@property (nonatomic,assign) CGFloat defaultMarginTop;
//添加view
- (void)cs_addFlowlayoutSubView:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view;
//移除view
- (void)cs_removeFlowlayoutSubView:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view;
//移除所有subview
- (void)cs_clearFlowlayoutSubview;
//重新计算所有subview的frame
- (void)cs_resetSubviewFrames;
//更新view和后续相关的view的frame
- (void)cs_updateFlowlayoutSubview:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view;
//view所在行
- (NSInteger)cs_rowForView:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view;
//view所在列
- (NSInteger)cs_columnForView:(nullable UIView<CSFlowlayoutSubviewProtocol> *)view;
@end

NS_ASSUME_NONNULL_END
