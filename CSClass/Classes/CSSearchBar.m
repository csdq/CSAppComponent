//
//  CSSearchBar.m
//  OA
//
//  Created by Mr.s on 16/7/22.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import "CSSearchBar.h"
#import "CSBaseSetting.h"
@interface CSSearchBar()<UITextFieldDelegate>
{
    UITextField *_searchTF;
    UIButton *_cancelBtn;
    NSLayoutConstraint *_cancleBtnWidth;
    NSLayoutConstraint *_searchTextRightMargin;
}
@property (nonatomic , strong) UIImage *leftImg;
@end

@implementation CSSearchBar
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setSubViews];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSubViews];
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor{
    [super setTintColor:tintColor];
    _searchTF.tintColor = tintColor;
    _cancelBtn.backgroundColor = tintColor;
}

- (void)setSubViews{
    self.backgroundColor = [[UIColor alloc] initWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1];//[UIColor colorFromHexRGB:@"CCCCCC"];
    _searchTF = [[UITextField alloc] init];
    _searchTF.borderStyle = UITextBorderStyleRoundedRect;
    _searchTF.delegate = self;
    _searchTF.font = [UIFont systemFontOfSize:14];
    _searchTF.backgroundColor = [UIColor whiteColor];
    _searchTF.returnKeyType = UIReturnKeySearch;
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTF.rightViewMode = UITextFieldViewModeWhileEditing;
   
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _cancelBtn.layer.borderWidth = 1;
    _cancelBtn.clipsToBounds = YES;
    _cancelBtn.layer.cornerRadius = 4;
    _searchTF.translatesAutoresizingMaskIntoConstraints = NO;
//    _cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelBtn setTitle:NSLocalizedStringFromTableInBundle(@"CancelBtnTitle", @"Localizable", [CSBaseSetting cs_base_res_bundle], @"取消") forState:UIControlStateNormal];
    _cancelBtn.backgroundColor = self.tintColor;
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_cancelBtn addTarget:self action:@selector(endSearch) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_searchTF];
     _searchTF.rightView = _cancelBtn;
//    [self addSubview:_cancelBtn];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_searchTF]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_searchTF)]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cancelBtn]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_searchTF]-6-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_searchTF)]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_cancelBtn]-6-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelBtn)]];
//    _cancleBtnWidth = [NSLayoutConstraint constraintWithItem:_cancelBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:0 constant:0];
    _searchTextRightMargin = [NSLayoutConstraint constraintWithItem:_searchTF attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-16.0];
    [self addConstraints:@[_searchTextRightMargin]];
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"CSBase" ofType:@"bundle"]];
    self.leftImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"common_search" ofType:@"png"]];
    
//    [[_searchTF rac_valuesAndChangesForKeyPath:@"text" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTuple* x) {
//        if([_delegate respondsToSelector:@selector(searchBar:textDidChange:)]){
//            [_delegate searchBar:self textDidChange:[x.allObjects firstObject]];
//        }
//    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)cs_becomeFirstResponder{
    [_searchTF becomeFirstResponder];
}

- (BOOL)cs_canBecomeFirstResponder{
    return [_searchTF canBecomeFirstResponder];
}

- (void)layoutSubviews{
    [super layoutSubviews];
     self->_cancelBtn.frame = CGRectMake(0, 0, 64, self->_searchTF.frame.size.height);
}

- (void)handleTextFieldDidChangeNotification:(NSNotification *)noti{
    if([noti.object isEqual:_searchTF] && [_delegate respondsToSelector:@selector(searchBar:textDidChange:)]){
        [_delegate searchBar:self textDidChange:[((UITextField *)noti.object) text]];
    }
}

- (void)setLeftImg:(UIImage *)leftImg{
    _leftImg = leftImg;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:(CGRect){0,0,24,24}];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image = _leftImg;
    _searchTF.leftView = imgView;
    _searchTF.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setPlaceholder:(NSString *)placeholder{
    _searchTF.placeholder = placeholder;
}

- (NSString *)text{
    return _searchTF.text;
}

- (void)setText:(NSString *)text{
    _searchTF.text = text;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton{
    _showsCancelButton = showsCancelButton;
//    if(self->_showsCancelButton){
////        self->_cancleBtnWidth.constant = 60;
//        self->_searchTextRightMargin.constant = -84;
//    }else{
////        self->_cancleBtnWidth.constant = 0;
//        self->_searchTextRightMargin.constant = -16;
//    }
    [UIView animateWithDuration:0.3 animations:^{
        [self updateConstraints];
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.showsCancelButton = YES;
    self.searchMode = @(YES);
    if([_delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]){
        return [_delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
       if([_delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]){
        return [_delegate searchBarShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
//replacementString:(NSString *)string{
//    NSMutableString *mStr = [NSMutableString stringWithString:_searchTF.text==nil?@"":_searchTF.text];
//    [mStr replaceCharactersInRange:range withString:string];
//    if([_delegate respondsToSelector:@selector(searchBar:textDidChange:)]){
//        [_delegate searchBar:self textDidChange:mStr];
//    }
//    return YES;
//}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([_delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]){
        [_delegate searchBarSearchButtonClicked:self];
    }
    return YES;
}

- (void)endSearch{
    self.showsCancelButton = NO;
    self.searchMode = @(NO);
    [_searchTF resignFirstResponder];
    if([_delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]){
        [_delegate searchBarCancelButtonClicked:self];
    }
}

@end
