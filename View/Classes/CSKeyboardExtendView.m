//
//  CSKeyboardExtendView.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/26.
//

#import "CSKeyboardExtendView.h"
#import "CSBaseSetting.h"
@implementation CSKeyboardExtendView

- (instancetype)initWithType:(CSAccessViewType)type
{
    self = [super init];
    if (self) {
         [self setSubViewWithType:type];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setSubViewWithType:CSAccessTypeNormal];
    }
    return self;
}

- (void)setSubViewWithType:(CSAccessViewType)type{    
    UIBarButtonItem *defaultKBBtn = [[UIBarButtonItem alloc] initWithTitle:@"键盘切换" style:UIBarButtonItemStyleDone target:self action:@selector(chgeKB:)];
    UIBarButtonItem *flxBtn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flxBtn2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *flxBtn3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
   
    UIBarButtonItem *finishBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"完成", @"Localizable", [CSBaseSetting cs_base_res_bundle], @"完成") style:UIBarButtonItemStyleDone target:self action:@selector(finshMethod:)];
    finishBtn.tintColor = [UIColor blackColor];
    defaultKBBtn.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *xBtn;
    UIBarButtonItem *eBtn;
    UIBarButtonItem *slantBtn;
    switch (type) {
        case CSAccessTypeIDNum:
            xBtn = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStylePlain target:self action:@selector(appendLetterX)];
            xBtn.tintColor = [UIColor blackColor];
            self.items = @[defaultKBBtn,flxBtn1,xBtn,flxBtn2,finishBtn];
            break;
        case CSAccessTypeHospitalNo:
            eBtn = [[UIBarButtonItem alloc] initWithTitle:@"E" style:UIBarButtonItemStylePlain target:self action:@selector(appendLetterE)];
            eBtn.tintColor = [UIColor blackColor];
            self.items = @[defaultKBBtn,flxBtn1,eBtn,flxBtn2,finishBtn];
            break;
        case CSAccessTypeBarcode:
            slantBtn = [[UIBarButtonItem alloc] initWithTitle:@"/" style:UIBarButtonItemStylePlain target:self action:@selector(appendSlant)];
            slantBtn.tintColor = [UIColor blackColor];
            self.items = @[defaultKBBtn,flxBtn1,slantBtn,flxBtn2,finishBtn];
            break;
        case CSAccessTypeNormal:
             self.items = @[defaultKBBtn,flxBtn1,finishBtn];
        default:
            break;
    }
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0f);
}

- (void)setInputControl:(id)inputControl{
    _inputControl = inputControl;
    if(_inputControl!=nil && [_inputControl respondsToSelector:@selector(keyboardAppearance)]){
        UIKeyboardAppearance kbAppearance = UIKeyboardAppearanceDefault;
        if([_inputControl isKindOfClass:[UITextField class]]){
            kbAppearance = ((UITextField *)_inputControl).keyboardAppearance;
        }
        if([_inputControl isKindOfClass:[UITextView class]]){
            kbAppearance = ((UITextView *)_inputControl).keyboardAppearance;
        }
        switch(kbAppearance){
            case UIKeyboardAppearanceDark:
                [self.items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.tintColor = [UIColor whiteColor];
                }];
                self.barStyle = UIBarStyleBlack;
                break;
            case UIKeyboardAppearanceLight:
            case UIKeyboardAppearanceDefault:
                [self.items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.tintColor = [UIColor blackColor];
                }];
                self.barStyle = UIBarStyleDefault;
                break;
        }
        
    }
}

- (void)appendSlant{
    if(self.inputControl){
        if([self.inputControl isKindOfClass:[UITextField class]]){
            if(((UITextField *)self.inputControl).text == nil){
                ((UITextField *)self.inputControl).text = @"/";
            }else{
                ((UITextField *)self.inputControl).text = [((UITextField *)self.inputControl).text stringByAppendingString:@"/"];
            }
        }else if([self.inputControl isKindOfClass:[UITextView class]]){
            if(((UITextView *)self.inputControl).text == nil){
                ((UITextView *)self.inputControl).text = @"/";
            }else{
                ((UITextView *)self.inputControl).text = [((UITextView *)self.inputControl).text stringByAppendingString:@"/"];
            }
        }
    }
}

- (void)appendLetterE{
    if(self.inputControl){
        if([self.inputControl isKindOfClass:[UITextField class]]){
            if(((UITextField *)self.inputControl).text == nil){
                ((UITextField *)self.inputControl).text = @"E";
            }else{
                ((UITextField *)self.inputControl).text = [((UITextField *)self.inputControl).text stringByAppendingString:@"E"];
            }
            
        }else if([self.inputControl isKindOfClass:[UITextView class]]){
            if(((UITextView *)self.inputControl).text == nil){
                ((UITextView *)self.inputControl).text = @"E";
            }else{
                ((UITextView *)self.inputControl).text = [((UITextView *)self.inputControl).text stringByAppendingString:@"E"];
            }
        }
    }
}

- (void)appendLetterX{
    if(self.inputControl){
        if([self.inputControl isKindOfClass:[UITextField class]]){
            if(((UITextField *)self.inputControl).text == nil){
                ((UITextField *)self.inputControl).text = @"X";
            }else{
                ((UITextField *)self.inputControl).text = [((UITextField *)self.inputControl).text stringByAppendingString:@"X"];
            }
            
        }else if([self.inputControl isKindOfClass:[UITextView class]]){
            if(((UITextView *)self.inputControl).text == nil){
                ((UITextView *)self.inputControl).text = @"X";
            }else{
                ((UITextView *)self.inputControl).text = [((UITextView *)self.inputControl).text stringByAppendingString:@"X"];
            }
        }
    }
}

- (void)finshMethod:(id)sender {
    if(self.inputControl != nil){
        if([self.inputControl isKindOfClass:[UITextView class]]){
            [((UITextView *)self.inputControl) resignFirstResponder];
            if(self.finishBlock){
                self.finishBlock(((UITextView *)self.inputView).text);
            }
        }else if([self.inputControl isKindOfClass:[UITextField class]]){
            [((UITextField *)self.inputControl) resignFirstResponder];
            if(self.finishBlock){
                self.finishBlock(((UITextField *)self.inputView).text);
            }
        }
    }   
}

- (void)chgeKB:(UIBarButtonItem *)barItem{
    if(self.inputControl){
        if([self.inputControl isKindOfClass:[UITextField class]]){
            if(((UITextField *)self.inputControl).keyboardType == UIKeyboardTypeDecimalPad){
                ((UITextField *)self.inputControl).keyboardType = UIKeyboardTypeDefault;
            }else{
                ((UITextField *)self.inputControl).keyboardType = UIKeyboardTypeDecimalPad;
            }
            [((UITextField *)self.inputControl) resignFirstResponder];
            [((UITextField *)self.inputControl) becomeFirstResponder];
        }else if([self.inputControl isKindOfClass:[UITextView class]]){
            if(((UITextView *)self.inputControl).keyboardType == UIKeyboardTypeDecimalPad){
                ((UITextView *)self.inputControl).keyboardType = UIKeyboardTypeDefault;
            }else{
                ((UITextView *)self.inputControl).keyboardType = UIKeyboardTypeDecimalPad;
            }
            [((UITextView *)self.inputControl) resignFirstResponder];
            [((UITextView *)self.inputControl) becomeFirstResponder];
        }
    }
    if(self.chgKBBlock){
        self.chgKBBlock();
    }
}
@end
