//
//  CSNavigationBar.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/11.
//

#import "CSNavigationBar.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CSBaseSetting.h"
#import "UIImage+CSCustom.h"
#import "CSHelper.h"

CGFloat CS_NavgiationBar_Height = 44.0;
@interface CSNavigationBar()<UINavigationBarDelegate>
{
    ///自定义视图容器
    UIView *_containView;
    ///导航栏背景
    __weak UIView * _barBackgroundView;
    ///导航栏背景alpha
    CGFloat _barBackgroundViewAlpha;
}
@end
@implementation CSNavigationBar
//MARK: --获取对象实例--
+ (instancetype)navigationBar{
    return [CSNavigationBar new];
}
//MARK:初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self cs_setView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self cs_setView];
    }
    return self;
}
//MARK: --SYS 视图操作--
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
    [super insertSubview:view atIndex:index];
    //找到导航栏背景视图
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        NSString *className = @"_UIBarBackground";
        Class _UIBarBackgroundClass = NSClassFromString(className);
        if ([view isKindOfClass:_UIBarBackgroundClass]) {
            _barBackgroundView = view;
        }
    }else {
        NSString *className = @"_UINavigationBarBackground";
        Class _UINavigationBarBackgroundClass = NSClassFromString(className);
        if ([view isKindOfClass:_UINavigationBarBackgroundClass]) {
            _barBackgroundView = view;
        }
    }
    if(_barBackgroundView){
        //        导航栏背景 alpha值修改
        _barBackgroundView.alpha = _barBackgroundViewAlpha;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if(_barBackgroundView != nil){
        _barBackgroundView.alpha = _barBackgroundViewAlpha;
    }
}
//MARK:--设置子视图--
- (void)cs_setView{
    self.backgroundColor = [UIColor clearColor];
    self.barStyle = UIBarStyleBlack;
    self.translucent = NO;
    self.delegate = self;
    _barBackgroundViewAlpha = 1.0;
    _containView = ({
        ///容器
        UIView *content = [UIView new];
        content.backgroundColor = [UIColor clearColor];
        content.alpha = 1;
        [self addSubview:content];
        [content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        content;
    });
    _titleView = ({
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.width.mas_lessThanOrEqualTo(K_SCREEN_WIDTH);
            make.height.lessThanOrEqualTo(self.mas_height);
        }];
        label;
    });
    _backBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        [btn setTitle:NSLocalizedStringFromTableInBundle(@"返回", @"Localizable", [CSBaseSetting cs_base_res_bundle], @"返回") forState:UIControlStateNormal];
        UIImage *leftImg = [[UIImage imagePNGNamed:@"cs_base_nav_arrow_left" inBundle:[CSBaseSetting cs_base_res_bundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:leftImg forState:UIControlStateNormal];
        [btn setImage:leftImg forState:UIControlStateHighlighted];
        btn.tintColor = [UINavigationBar appearance].tintColor;
        btn.imageView.tintColor = [UINavigationBar appearance].tintColor;
        [btn setTitleColor: [UINavigationBar appearance].tintColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self.mas_centerY);
            make.width.mas_lessThanOrEqualTo(K_SCREEN_WIDTH * 0.4);
        }];
        @weakify(self)
        btn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self)
                [self.backBtnTouchInsideSubject sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
        btn;
    });
}


- (void)setTitle:(NSString *)title{
    _title = title;
    if([self.titleView isKindOfClass:[UILabel class]]){
        ((UILabel *)_titleView).text = (NSString *)_title;
    }else{
        [_titleView removeFromSuperview];
        _titleView = ({
            UILabel *label = [UILabel new];
            label.text = title;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:18];
            [self addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_centerX);
                make.centerY.equalTo(self.mas_centerY);
                make.width.mas_lessThanOrEqualTo(K_SCREEN_WIDTH);
                make.height.lessThanOrEqualTo(self.mas_height).priorityHigh();
            }];
            label;
        });
    }
}

- (void)setLeftView:(UIView *)leftView{
    if(_leftView && _leftView.superview){
        ///移除原有视图
        [_leftView removeFromSuperview];
    }
    _leftView = leftView;
    if(leftView){
        [self addSubview:_leftView];
        [self relayoutLeftView];
    }
}

- (void)setTitleView:(UIView *)titleView{
    if(_titleView && _titleView.superview){
        ///移除原有视图
        [_titleView removeFromSuperview];
    }
    _titleView = titleView;
    if(_titleView){
        [self addSubview:_titleView];
        [self relayoutTitleView];
    }
}

- (void)setRightView:(UIView *)rightView{
    if(_rightView && _rightView.superview){
        ///移除原有视图
        [_rightView removeFromSuperview];
    }
    _rightView = rightView;
    if(rightView){
        [self addSubview:_rightView];
        [self relayoutRightView];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    _containView.backgroundColor = backgroundColor;
}

- (void)relayoutLeftView{
    CGSize originSize = _rightView.frame.size;
    [_leftView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(originSize.height > 0){
            make.height.mas_equalTo(originSize.height).priorityLow();
        }else{
            make.height.mas_equalTo(44);
        }
        if(originSize.width > 0){
            make.width.mas_equalTo(originSize.width).priorityLow();
        }else{
            make.width.mas_equalTo(60);
        }
        if(self.backBtn && self.backBtn.superview && !self.backBtn.hidden && self.backBtn.alpha>0){
            //返回按钮显示
            make.left.equalTo(self.backBtn.mas_right);
        }else{
            make.left.equalTo(self.mas_left).offset(8);
        }
        make.height.mas_equalTo(originSize.height).priorityLow();
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(44);
        make.width.mas_lessThanOrEqualTo(K_SCREEN_WIDTH * 0.25).priorityHigh();
    }];
    [self layoutIfNeeded];
}

- (void)relayoutRightView{
    CGSize originSize = _rightView.frame.size;
    [_rightView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(originSize.height > 0){
            make.height.mas_equalTo(originSize.height).priorityLow();
        }else{
            make.height.mas_equalTo(44);
        }
        if(originSize.width > 0){
            make.width.mas_equalTo(originSize.width).priorityLow();
        }else{
            make.width.mas_equalTo(60);
        }
        make.right.equalTo(self.mas_right).offset(-8);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(44);
        make.width.mas_lessThanOrEqualTo(K_SCREEN_WIDTH * 0.25).priorityHigh();
        make.height.lessThanOrEqualTo(self.mas_height).priorityHigh();
    }];
    [self layoutIfNeeded];
}

- (void)relayoutTitleView{
    CGSize originSize = _titleView.frame.size;
    [_titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(originSize.height > 0){
            make.height.mas_equalTo(originSize.height).priorityLow();
        }
        if(originSize.width > 0){
            make.width.mas_equalTo(originSize.width).priorityLow();
        }
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_lessThanOrEqualTo(K_SCREEN_WIDTH);
        make.height.lessThanOrEqualTo(self.mas_height).priorityHigh();
    }];
    [self layoutIfNeeded];
}

- (void)changeBackgroundAlpha:(CGFloat)alpha{
    _barBackgroundViewAlpha = alpha;
    if(_barBackgroundView){
        _barBackgroundView.alpha = alpha;
    }
}

- (RACSubject *)backBtnTouchInsideSubject{
    if(!_backBtnTouchInsideSubject){
        _backBtnTouchInsideSubject =  [RACSubject subject];
    }
    return _backBtnTouchInsideSubject;
}

- (void)setBackBtnTitle:(NSString *)title{
    [self.backBtn setTitle:title forState:UIControlStateNormal];
    [self.backBtn setTitle:title forState:UIControlStateHighlighted];
    [self updateConstraintsIfNeeded];
}

//MARK: delegate
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}
@end
