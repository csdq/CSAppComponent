//
//  CSKeyboardExtendView.h
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/26.
//

#import <UIKit/UIKit.h>

@interface CSKeyboardExtendView : UIToolbar

typedef void(^FinishBlock)(NSString *value);
typedef void(^ChgKBBlock)(void);

typedef enum CSAccessViewType{
    CSAccessTypeNormal = 0,
    CSAccessTypeBarcode,
    CSAccessTypeHospitalNo,
    CSAccessTypeIDNum
}CSAccessViewType;

@property (nonatomic , copy) FinishBlock finishBlock;
@property (nonatomic , copy) ChgKBBlock chgKBBlock;
@property (nonatomic , weak) id inputControl;
- (instancetype)initWithType:(CSAccessViewType)type;
@end

