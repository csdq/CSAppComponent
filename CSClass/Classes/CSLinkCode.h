//
//  CSLinkCode.h
//  CSLink
//
//  Created by Mr.s on 2017/3/16.
//  Copyright © 2017年 Mr.s. All rights reserved.
//

#ifndef CSLinkCode_h
#define CSLinkCode_h

#define _UU_ __attribute__((unused))

#define CS_LC_METHOD(self_type,arg_type,method_name)\
- (self_type * (^)(arg_type * value))method_name;
#define CS_LC_METHOD_IMP(self_type,arg_type,method_name,code)\
- (self_type * (^)(arg_type * value))method_name{typeof(self) wSelf _UU_ = self; return ^self_type * (arg_type * value){({code});return self;};}
//
#define CS_LC_METHOD_VOID(self_type,method_name)\
- (self_type * (^)(void))method_name;
#define CS_LC_METHOD_VOID_IMP(self_type,method_name,code)\
- (self_type * (^)(void))method_name{typeof(self) wSelf _UU_ = self;return ^self_type * (void){({code});return self;};}
//
#define CS_LC_METHOD_ARG_ASSIGN(self_type,arg_type,method_name)\
- (self_type * (^)(arg_type value))method_name;
#define CS_LC_METHOD_IMP_ARG_ASSIGN(self_type,arg_type,method_name,code)\
- (self_type * (^)(arg_type value))method_name{typeof(self) wSelf _UU_ = self;return ^self_type * (arg_type value){({code});return self;};}


#endif /* CSLinkCode_h */
