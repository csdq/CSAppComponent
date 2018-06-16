//
//  CSBaseCollectionViewCell.m
//  CSAppComponent
//
//  Created by Mr.s on 2017/4/3.
//

#import "CSBaseCollectionViewCell.h"

@implementation CSBaseCollectionViewCell
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self cs_setView];
    }
    return self;
}
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

- (void)cs_setView{
    
}
@end
