//
//  CSBaseTableViewCell.m
//  CSAppComponent
//
//  Created by Mr.s on 2017/4/3.
//

#import "CSBaseTableViewCell.h"

@implementation CSBaseTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self cs_setView];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self cs_setView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self cs_setView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cs_setView{
    
}

@end
