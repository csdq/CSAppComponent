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
@property (nonatomic , strong) NSString *text;
@property (nonatomic , strong) NSString *placeholder;
@property (nonatomic , assign) BOOL showsCancelButton;
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

