//
//  CSSearchBar.h
//  OA
//
//  Created by Mr.s on 16/7/22.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma  mark - SearchBar
@interface CSSearchBar : UIView
///搜索输入框内的数据
@property (nonatomic , strong) NSString *text;
///搜索输入框占位符
@property (nonatomic , strong) NSString *placeholder;
///搜索图标
@property (nonatomic , strong) UIImage *leftImg;
///是否显示取消按钮
@property (nonatomic , assign) BOOL showsCancelButton;
///是否正在搜索
@property (nonatomic , strong) NSNumber *searchMode;
- (void)cs_becomeFirstResponder;
- (BOOL)cs_canBecomeFirstResponder;
- (void)endSearch;
@end

@protocol CSSearchBarDelegate<NSObject>
@optional
- (void)searchBar:(CSSearchBar *)searchBar textDidChange:(NSString *)searchText;
- (BOOL)searchBarShouldBeginEditing:(CSSearchBar *)searchBar;
- (BOOL)searchBarShouldEndEditing:(CSSearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(CSSearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(CSSearchBar *)searchBar;
@end

@interface CSSearchBar()
@property (nonatomic , weak) id<CSSearchBarDelegate> delegate;
@end

