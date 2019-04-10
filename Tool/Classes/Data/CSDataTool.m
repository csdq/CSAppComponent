//
//  CSDataTool.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/26.
//

#import "CSDataTool.h"
#import "CSDataSecurity.h"

NSTimeInterval CSTimeIntervalMinute = 60.0;
NSTimeInterval CSTimeIntervalHour = 3600.0;
NSTimeInterval CSTimeIntervalDay = 86400;
NSTimeInterval CSTimeIntervalWeek = 604800;

@implementation CSDateWeek
- (NSString *)startDateStr{
    return [[CSDataTool sharedInstance].dateFormatterDate stringFromDate:self.startDate];
}

- (NSString *)startStrCh{
    return [[CSDataTool sharedInstance].dateFormatterChinese stringFromDate:self.startDate];
}

- (NSString *)endDateStr{
    return [[CSDataTool sharedInstance].dateFormatterDate stringFromDate:self.endDate];
}

- (NSString *)endStrCh{
    return [[CSDataTool sharedInstance].dateFormatterChinese stringFromDate:self.endDate];
}

+ (CSDateWeek *)getWeekObjWithDate:(NSDate *)date{
    CSDateWeek *weekObj = [CSDateWeek new];
    weekObj.date = date;
    NSCalendar *cal = [CSDataTool sharedInstance].calender;
    NSDate *startOfTheWeek;
    NSDate *endOfWeek;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSCalendarUnitWeekOfMonth
           startDate:&startOfTheWeek
            interval:&interval
             forDate:date];
    weekObj.indexOfWeekInMonth = [cal ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitMonth forDate:startOfTheWeek];
    endOfWeek = [startOfTheWeek dateByAddingTimeInterval:interval-1];
    weekObj.startDate = startOfTheWeek;
    weekObj.endDate = endOfWeek;
    return weekObj;
}

- (CSDateWeek *)getNextWeekObj{
    return [CSDateWeek getWeekObjWithDate:[self.startDate dateByAddingTimeInterval:7*24*3600]];
}

- (CSDateWeek *)getPreviousWeekObj{
    return [CSDateWeek getWeekObjWithDate:[self.startDate dateByAddingTimeInterval:-7*24*3600]];
}

- (NSString *)description{
    return [self objDescription];
}

- (NSString *)debugDescription{
    return [self objDescription];
}

- (NSString *)objDescription{
    return [NSString stringWithFormat:@"Week Object:\nStart Date:%@\nEnd Date%@",self.startDate,self.endDate];
}
@end

@interface CSDataTool()
@property (nonatomic,strong) NSRegularExpression *regNum;
@property (nonatomic,strong) NSRegularExpression *regLowerLetter;
@property (nonatomic,strong) NSRegularExpression *regUpperLetter;
@property (nonatomic,strong) NSRegularExpression *regSymbol;
@end

@implementation CSDataTool
static CSDataTool *_instance;

+ (instancetype)sharedInstance{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instance = [[CSDataTool alloc] init];
    });
    return _instance;
}

- (NSRegularExpression *)regUpperLetter{
    if(_regUpperLetter == nil){
        _regUpperLetter = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]+" options:0 error:nil];
    }
    return _regUpperLetter;
}

- (NSRegularExpression *)regLowerLetter{
    if(_regLowerLetter == nil){
        _regLowerLetter = [NSRegularExpression regularExpressionWithPattern:@"[a-z]+" options:0 error:nil];
    }
    return _regLowerLetter;
}

- (NSRegularExpression *)regNum{
    if(_regNum == nil){
        _regNum = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:nil];
    }
    return _regNum;
}

- (NSRegularExpression *)regSymbol{
    if(_regSymbol == nil){
        _regSymbol = [NSRegularExpression regularExpressionWithPattern:@"[/:;()$&@\"\\.,\\?!'\\[\\]{}#%^*+=_\\\\|~<>€£¥• -]+" options:0 error:nil];
    }
    return _regSymbol;
}

+ (BOOL)isCellPhoneNum:(NSString *)str{
    return [str length] == 11;
}
+ (NSString *)getIdCardCheckNum:(NSString *)idCardNum{
    if([idCardNum length] < 17){
        return @"";
    }else{
        int result = 0;
        NSString *lastNum = nil;
        for (int i = 0; i < 17; i++) {
            result += ([[idCardNum substringWithRange:NSMakeRange(i, 1)] intValue]<<(17-i))%11;
        }
        switch (result%11){
            case 0:lastNum = @"1";break;
            case 1:lastNum = @"0";break;
            case 2:lastNum = @"X";break;
            case 3:lastNum = @"9";break;
            case 4:lastNum = @"8";break;
            case 5:lastNum = @"7";break;
            case 6:lastNum = @"6";break;
            case 7:lastNum = @"5";break;
            case 8:lastNum = @"4";break;
            case 9:lastNum = @"3";break;
            case 10:lastNum = @"2";break;
            default:break;
        }
        return lastNum;
    }
}

+ (BOOL)isIDCardNum:(NSString *)str{
    //15位转18
//    if(15 == [str length]){
//        str = [NSString stringWithFormat:@"%@19%@",[str substringWithRange:NSMakeRange(0, 8)],[str substringWithRange:NSMakeRange(8, 7)]];
//        str = [str stringByAppendingString:[self getIdCardCheckNum:str]];
//    }
    if([str length] != 18){
        return NO;
    }else{
        NSString *lastNum = [self getIdCardCheckNum:str];
        return [lastNum isEqualToString:[[str substringWithRange:NSMakeRange(17, 1)] uppercaseString]];
    }
}

+ (NSNumber *)isMale:(NSString *)idCardNum{
    //    NSAssert([self isIDCardNum:idCardNum], @"Invalid ID Card Num");
    if([self isIDCardNum:idCardNum]){
        return @([[idCardNum substringWithRange:NSMakeRange(16, 1)] integerValue]%2 == 1);
    }else{
        return nil;
    }
//    if(idCardNum.length==18){
//    }else{
//        return [[idCardNum substringWithRange:NSMakeRange(14, 1)] integerValue]%2 == 1;
//    }
}

+ (NSDate *)getBirthDate:(NSString *)idCardNum cardNumVerify:(BOOL)yesOrNo{
    NSString *dateStr = nil;
    if(yesOrNo){
        if([self isIDCardNum:idCardNum]){
            dateStr = [idCardNum substringWithRange:NSMakeRange(6, 8)];
        }
    }else{
        if(idCardNum.length>14){
            dateStr = [idCardNum substringWithRange:NSMakeRange(6, 8)];
        }
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    return [dateFormatter dateFromString:dateStr];
}

+ (NSString *)getBirthDateString:(NSString *)idCardNum cardNumVerify:(BOOL)yesOrNo{
    NSDate *date = [self getBirthDate:idCardNum cardNumVerify:yesOrNo];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter stringFromDate:date];
}

///验证是否是邮箱
+ (BOOL)isValidEmail:(NSString *)email{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z0-9]{2,6}$"];
    return [predicate evaluateWithObject:email];
}

///密码强度是否足够
+ (BOOL)isPasswordStrongerThanWeak:(NSString *)passwd{
    CSPasswordStrength strength = [self passwordStrength:passwd];
    return strength == CSPasswordStrongest || strength == CSPasswordStrong || strength == CSPasswordNormal;
}

+ (BOOL)isStrongPassword:(NSString *)str{
    CSPasswordStrength strength = [self passwordStrength:str];
    return strength == CSPasswordStrongest || strength == CSPasswordStrong;
}

//密码强度
+ (CSPasswordStrength)passwordStrength:(NSString *)passwd{
    
    NSPredicate * predicateValid = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[\u4E00-\u9FA5]"];//包含了中文 其他不符合要求的字符 待增加
    //除了密码为空，密码长度不考虑
    if([passwd length] == 0 || [predicateValid evaluateWithObject:passwd]){
        return CSPasswordInvalid;
    }
    NSInteger hasUpperLetter = [[[CSDataTool sharedInstance].regUpperLetter matchesInString:passwd options:NSMatchingReportProgress range:NSMakeRange(0, passwd.length)] count] > 0?1:0;
    NSInteger hasLowLetter = [[[CSDataTool sharedInstance].regLowerLetter matchesInString:passwd options:NSMatchingReportProgress range:NSMakeRange(0, passwd.length)] count] > 0?1:0;
    NSInteger hasNum = [[[CSDataTool sharedInstance].regNum matchesInString:passwd options:NSMatchingReportProgress range:NSMakeRange(0, passwd.length)] count] > 0?1:0;
    NSInteger hasSymbol =[[[CSDataTool sharedInstance].regSymbol matchesInString:passwd options:NSMatchingReportProgress range:NSMakeRange(0, passwd.length)] count] > 0?1:0;
    NSInteger result = hasNum + hasLowLetter + hasUpperLetter + hasSymbol;
    switch (result) {
        case 0:
        default:return CSPasswordInvalid;
        case 1:return CSPasswordWeak;
        case 2:return CSPasswordNormal;
        case 3:return CSPasswordStrong;
        case 4:return CSPasswordStrongest;
    }
}
+ (NSString *)dataToHexStr:(NSData *)data {
    NSString *strTemp = @"0123456789ABCDEF";
    
    NSMutableString *retStr = [NSMutableString string];
    
    const Byte *bs = [data bytes];
    int bit;
    for (int i = 0; i < data.length; i++) {
        bit = (bs[i] & 0x0f0) >> 4;
        [retStr appendString:[strTemp substringWithRange:NSMakeRange(bit, 1)]];
        bit = bs[i] & 0x0f;
        [retStr appendString:[strTemp substringWithRange:NSMakeRange(bit, 1)]];
    }
    return retStr;
}

+ (NSData *)hexStrToData:(NSString *)str {
    NSString *strTemp = @"0123456789ABCDEF";
    
    Byte *bytes = (Byte *)[[NSMutableData dataWithCapacity:str.length/2]bytes];
    
    NSInteger n;
    for (int i = 0; i < str.length/2; i++) {
        n = [strTemp rangeOfString:[str substringWithRange:NSMakeRange(2*i, 1)]].location << 4;
        n += [strTemp rangeOfString:[str substringWithRange:NSMakeRange(2*i+1, 1)]].location;
        bytes[i] = (Byte) (n & 0xff);
    }
    NSData *data = [NSData dataWithBytes:bytes length:str.length/2];
    return data;
}

+ (NSString *)pinyinFromMandrin:(NSString *)string{
    NSString *mandStr = [NSString stringWithString:string];
    CFMutableStringRef mStrRef = CFStringCreateMutableCopy(NULL, 0,(__bridge CFStringRef)mandStr);
    Boolean result = CFStringTransform(mStrRef, NULL, kCFStringTransformMandarinLatin, NO);
    if(result){
        NSString *pinyinStr = [(__bridge NSMutableString*)mStrRef copy];
        CFRelease(mStrRef);
        return pinyinStr;
    }else{
        CFRelease(mStrRef);
        return @"#Error";
    }
}

+ (NSString *)pinyinWithoutToneFromMandrin:(NSString *)string{
    CFMutableStringRef mStrRef = CFStringCreateMutableCopy(NULL, 0,(__bridge CFStringRef)string);
    Boolean result = CFStringTransform(mStrRef, NULL, kCFStringTransformMandarinLatin, NO);
    if(result){
        result = CFStringTransform(mStrRef, NULL, kCFStringTransformStripDiacritics, NO);
        if(result){
            NSString *pinyinStr = [(__bridge NSMutableString*)mStrRef copy];
            CFRelease(mStrRef);
            return pinyinStr;
        }
    }
    CFRelease(mStrRef);
    return @"#Error";
}

+ (NSString *)getMD5:(NSString *)string {
    return [[self md5:string] uppercaseString];
}

+ (NSString *)getMD5InMD5:(NSString *)string{
    return [[self md5:[[self md5:string] uppercaseString]] uppercaseString];
}

+ (NSString *)md5:(NSString *)string {
    return [CSDataSecurity md5:string];
}

+ (NSString *)rsaEncryption:(NSString *)str prikey:(NSString *)key{
    return [CSDataSecurity rsa_encryptString:str privateKey:key];
}

+ (NSString *)rsaDecryption:(NSString *)str pubkey:(NSString *)key{
    return [CSDataSecurity rsa_decryptString:str publicKey:key];
}

+ (NSString *)rsaEncryption:(NSString *)str pubkey:(NSString *)key{
    return [CSDataSecurity rsa_encryptString:str publicKey:key];
}

+ (NSString *)rsaDecryption:(NSString *)str prikey:(NSString *)key{
    return [CSDataSecurity rsa_decryptString:str privateKey:key];
}

+ (NSString *)aesEncrption:(NSString *)str key:(NSString *)key{
    return [CSDataSecurity aes_encryptString:str password:key];
}

+ (NSString *)aesDecryption:(NSString *)str key:(NSString *)key{
    return [CSDataSecurity aes_decryptString:str password:key];
}

+ (NSString *)desEncrption:(NSString *)str key:(NSString *)key{
     return [CSDataSecurity des_decryptString:str password:key];
}

+ (NSString *)desDecryption:(NSString *)str key:(NSString *)key{
     return [CSDataSecurity des_decryptString:str password:key];
}

+ (NSString *)encodeBase64String:(NSString *)string{
    return [self base64EncodedStringFrom:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)decodeBase64String:(NSString *)string{
    return [[NSString alloc] initWithData:[self dataWithBase64EncodedString:string] encoding:NSUTF8StringEncoding];
}

+ (NSData *)getDataFromBase64String:(NSString *)string{
    return [self dataWithBase64EncodedString:string];
}

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

// base64字符串转换成data
+ (NSData *)dataWithBase64EncodedString:(NSString *)string {
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:@" dataWithBase64EncodedString"];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

// data转换成base64字符串
+ (NSString *)base64EncodedStringFrom:(NSData *)data {
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

+ (NSString *)urlEncode:(NSString *)url{
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
}

+ (NSString *)urlDecode:(NSString *)url{
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)url,                                              CFSTR(""),                          CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

+ (NSString *)htmlEncode:(NSString *)string{
    return [[string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    //  return [[[NSAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil] string];
}

+ (NSString *)htmlDecode:(NSString *)string{
    return [[string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"] stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    //    return [[[NSAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSPlainTextDocumentType} documentAttributes:nil error:nil] string];
}

+ (NSString *)htmlToText:(NSString *)htmlString{
    if(htmlString==nil){
        htmlString = @"";
    }
    NSRegularExpression *regularExpretion = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n|\t|\r" options:0 error:nil];
    return [regularExpretion stringByReplacingMatchesInString:htmlString options:NSMatchingReportProgress range:NSMakeRange(0, htmlString.length) withTemplate:@""];
}

+ (NSAttributedString *)htmlDocumentTypeAttriStringFromHtmlString:(NSString *)htmlString{
    return [[NSAttributedString alloc] initWithData:[[@"<meta charset=\"UTF-8\">" stringByAppendingString:htmlString==nil?@"":htmlString] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}  documentAttributes:nil error:nil];
}

+ (NSAttributedString *)highlightKeywordString:(NSString *)string keyword:(NSString *)keyword  originalAttrDict:(NSDictionary *)oDict highLighted:(NSDictionary *)hDict{
    if(string == nil){
        return nil;
    }
    NSRange range1 = [string rangeOfString:keyword];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string attributes:oDict];
    [attr setAttributes:hDict range:range1];
    return attr;
}

+ (NSDateComponents *)getAgeWithIDCardNum:(NSString *)idCard{
    NSDateComponents *dateCom  = nil;
    NSString *dateStr = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"Asia/Shanghai"];
    if(idCard.length == 15){
        dateStr = [@"19" stringByAppendingString:[idCard substringWithRange:NSMakeRange(6, 6)]];
    }else if(idCard.length == 18){
        dateStr = [idCard substringWithRange:NSMakeRange(6, 8)];
    }else{
        dateStr = nil;
    }
    
    if(dateStr != nil){
        NSDate *date = [formatter dateFromString:dateStr];
        // 日历
        NSCalendar *calendar = [NSCalendar currentCalendar];
        // 日期对比项
        NSUInteger unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
        dateCom = [calendar components:unitFlags fromDate:date toDate:[NSDate date] options:NSCalendarMatchStrictly];
    }
    return dateCom;
}

+ (NSString *)getAgeStrFromIDCardNum:(NSString *)idCard{
    NSString *resultAge = @"未知";
    NSDateComponents *dateCom = [self getAgeWithIDCardNum:idCard];
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"CSAppComponent" ofType:@"bundle"]];
    if(dateCom!=nil){
        if(dateCom.year==0){
            if(dateCom.month==0){
                resultAge = [NSString stringWithFormat:@"%ld%@",(long)dateCom.weekday,NSLocalizedStringFromTableInBundle(@"周", @"Localizable", bundle, @"周")];
            }else{
                resultAge = [NSString stringWithFormat:@"%ld%@",(long)dateCom.month,NSLocalizedStringFromTableInBundle(@"月", @"Localizable", bundle, @"月")];
            }
        }else{
            resultAge = [NSString stringWithFormat:@"%ld%@",(long)dateCom.year,NSLocalizedStringFromTableInBundle(@"岁", @"Localizable",  bundle, @"岁")];
        }
    }
    return resultAge;
}

+ (CGSize)getTextSizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    return [self getTextSizeWithText:text font:font maxSize:maxSize paragraph:nil];
}

+ (CGSize)getTextSizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize paragraph:(NSParagraphStyle *)paragraph{
    CGSize size = CGSizeZero;
    if(text == nil){
        text = @"";
    }
    if(font == nil){
        font = [UIFont systemFontOfSize:14];
    }
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,paragraph,NSParagraphStyleAttributeName,nil];
    size = [text boundingRectWithSize:maxSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size;
}

/********/
- (NSCalendar *)calender{
    if(_calender == nil){
        _calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
        _calender.locale = [NSLocale localeWithLocaleIdentifier:@"zh_cn"];
        _calender.timeZone = [NSTimeZone timeZoneWithName:@"GMT+8"];
        _calender.firstWeekday = 2;
    }
    return _calender;
}

- (NSDateFormatter *)dateFormatterChinese{
    if(_dateFormatterChinese == nil){
        _dateFormatterChinese = [[NSDateFormatter alloc] init];
        _dateFormatterChinese.dateFormat = @"yyyy年M月d日";
    }
    return _dateFormatterChinese;
}
- (NSDateFormatter *)dateFormatterDate{
    if(_dateFormatterDate == nil){
        _dateFormatterDate = [[NSDateFormatter alloc] init];
        _dateFormatterDate.dateFormat = @"yyyy-MM-dd";
    }
    return _dateFormatterDate;
}
- (NSDateFormatter *)dateFormatterDateTime{
    if(_dateFormatterDateTime == nil){
        _dateFormatterDateTime = [[NSDateFormatter alloc] init];
        _dateFormatterDateTime.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFormatterDateTime;
}

- (NSDateFormatter *)dateFormatterReuse{
    if(_dateFormatterReuse == nil){
        _dateFormatterReuse = [[NSDateFormatter alloc] init];
        _dateFormatterReuse.locale = self.calender.locale;
    }
    return _dateFormatterReuse;
}

@end
