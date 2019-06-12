//
//  Helper.h
//   CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#ifndef Helper_h
#define Helper_h
#import "CSLinkCode.h"

//NSLog
//控制台输出 仅DEBUG模式启用
#ifdef DEBUG
#define NSLog(format, ...) do {\
fprintf(stderr, "-----------------------------------------\n");             \
fprintf(stderr, "File: %s / Func: %s / Line: %d\n",                         \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__func__, __LINE__);                                                        \
(NSLog((format), ##__VA_ARGS__));                                           \
fprintf(stderr, "-----------------------------------------\n\n");           \
} while (0)
#else
#define NSLog(format, ...) nil
#endif

//屏幕尺寸
#define K_SCREEN_BOUNDS ([UIScreen mainScreen].bounds)
#define K_SCREEN_SIZE  ([UIScreen mainScreen].bounds.size)
#define K_SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define K_SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)

//Nav bar height
#define K_NAV_BAR_HEIGHT 44.0
#define K_TAB_BAR_HEIGHT 49.0
#define K_STATUS_BAR_HEIGHT 20.0
#define K_IPHONE_X_BOTTOM_ADDITION_HEIGHT 34.0
//属性定义
#define CS_PROPERTY_DECLARE(class,name) @property (nonatomic, strong) class * name;
#define CS_PROPERTY_BLOCK_DECLARE(class,name) @property (nonatomic, copy) class name;
#define CS_PROPERTY_ASSIGN_DECLARE(type,name) @property (nonatomic, assign) type name;

///便捷宏方法 需要引用<Masonry/Masonry.h> 自动撑满控制器主视图
#define CS_ADD_MAIN_VIEW_AND_FULLFILL(Main_View) \
({@weakify(self);[self.view addSubview:Main_View];\
    [Main_View mas_makeConstraints:^(MASConstraintMaker *make) {\
@strongify(self);\
    if(@available(iOS 11,*)){make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);\
        make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);\
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);\
        make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);\
    }else{\
    if(self.cs_navigationBar.superview||([self.navigationController isKindOfClass:[CSNavViewController class]]&&((CSBaseNavViewController *)self.navigationController).useCustomNavigationBar)){\
        make.top.equalTo(self.mas_topLayoutGuide).offset(44);\
    }else{\
        make.top.equalTo(self.mas_topLayoutGuide);\
    }\
        make.right.equalTo(self.view.mas_right);\
        make.bottom.equalTo(self.mas_bottomLayoutGuide);\
        make.left.equalTo(self.view.mas_left);\
    }\
    }];\
});

#define CS_NO_STRING_VALUE(name) (name == nil || [name isKindOfClass:[NSNull class]] || [name length] == 0)
/*
 * 懒加载
 * class 属性类型
 * name  属性名称
 * code  代码块，返回属性实例对象
 */
#define CS_PROPERTY_INIT_CODE(class,name,code)\
- (class *)name{if(_##name == nil){_##name = \
(code);\
}return _##name;}

/*
 * 懒加载
 * class 属性类型
 * name  属性名称
 * code  代码块，返回属性实例对象
 */
#define CS_PROPERTY_ASSIGN_INIT_CODE(class,name,code)\
- (class)name{if(_##name == nil){_##name = \
(code);\
}return _##name;}

/*
 * 点语法 方法定义
 * return_type 返回类型
 * arg_type  参数类型
 * code  代码块
 */
#define CS_LINKCODE_METHOD(return_type,arg_type,method_name)\
CS_LC_METHOD(return_type,arg_type,method_name)
/*
 * 点语法 方法实现
 * return_type 返回类型
 * arg_type  参数类型
 * code  代码块
 */
#define CS_LINKCODE_METHOD_IMP(return_type,arg_type,method_name,code)\
CS_LC_METHOD_IMP(return_type,arg_type,method_name,code)
/*
 * 点语法 方法定义
 * return_type 返回类型
 * arg_type  参数类型
 * code  代码块
 */
#define CS_LINKCODE_METHOD_ASSIGN(return_type,arg_type,method_name)\
CS_LC_METHOD_ARG_ASSIGN(return_type,arg_type,method_name)
/*
 * 点语法 方法实现
 * return_type 返回类型
 * arg_type  参数类型
 * code  代码块
 */
#define CS_LINKCODE_METHOD_IMP_ASSIGN(return_type,arg_type,method_name,code)\
CS_LC_METHOD_IMP_ARG_ASSIGN(return_type,arg_type,method_name,code)

#define CS_LINKCODE_METHOD_VOID(return_type,method_name)\
CS_LC_METHOD_VOID(return_type,method_name)

#define CS_LINKCODE_METHOD_VOID_IMP(return_type,method_name,code)\
CS_LC_METHOD_VOID_IMP(return_type,method_name,code)
#endif /* Helper_h */

