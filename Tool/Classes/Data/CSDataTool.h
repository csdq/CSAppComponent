//
//  CSDataTool.h
//   CSAppComponent
//  数据处理类：数据验证、加密/解密、格式处理
//  Created by Mr.s on 2017/3/26.
//

#import <Foundation/Foundation.h>

extern NSTimeInterval CSTimeIntervalMinute;
extern NSTimeInterval CSTimeIntervalHour;
extern NSTimeInterval CSTimeIntervalDay;
extern NSTimeInterval CSTimeIntervalWeek;

typedef enum : NSUInteger {
    CSPasswordInvalid,
    CSPasswordWeak,
    CSPasswordNormal,
    CSPasswordStrong,
    CSPasswordStrongest
} CSPasswordStrength;

@interface CSDateWeek:NSObject
@property (nonatomic , strong) NSDate *date;
@property (nonatomic , strong) NSString *startDateStr;
@property (nonatomic , strong) NSString *endDateStr;
@property (nonatomic , strong) NSString *startStrCh;
@property (nonatomic , strong) NSString *endStrCh;
@property (nonatomic , strong) NSDate *startDate;
@property (nonatomic , strong) NSDate *endDate;
@property (nonatomic , assign) NSUInteger indexOfWeekInMonth;
+ (CSDateWeek *)getWeekObjWithDate:(NSDate *)date;
- (CSDateWeek *)getNextWeekObj;
- (CSDateWeek *)getPreviousWeekObj;
@end

@interface CSDataTool : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic , strong) NSCalendar *calender;
@property (nonatomic , strong) NSDateFormatter *dateFormatterDate;
@property (nonatomic , strong) NSDateFormatter *dateFormatterDateTime;
@property (nonatomic , strong) NSDateFormatter *dateFormatterChinese;
@property (nonatomic , strong) NSDateFormatter *dateFormatterReuse;
//MARK: 数据验证
///验证是否为正确的手机号码
+ (BOOL)isCellPhoneNum:(NSString *)str;
///验证身份证号码
+ (BOOL)isIDCardNum:(NSString *)str;
///身份证号 校验位
+ (NSString *)getIdCardCheckNum:(NSString *)str;
///通过身份证号判断男女 男 或者 女
+ (NSNumber *)isMale:(NSString *)idCardNum;
///密码强度是否足够
+ (BOOL)isStrongPassword:(NSString *)passwd;
///密码强度是否足够
+ (BOOL)isPasswordStrongerThanWeak:(NSString *)passwd;
//密码强度
+ (CSPasswordStrength)passwordStrength:(NSString *)passwd;
///验证是否是邮箱
+ (BOOL)isValidEmail:(NSString *)email;
//MARK:--数据处理--
//MARK:数据格式
/**
 *  date转化NSString
 *
 *  @param data utf8 data
 *
 *  @return string
 */
+ (NSString *)dataToHexStr:(NSData *)data;

+ (NSData *)hexStrToData:(NSString *)str;

+ (NSString *)encodeBase64String:(NSString *)string;

+ (NSString *)decodeBase64String:(NSString *)string;

+ (NSData *)getDataFromBase64String:(NSString *)string;

+ (NSString *)urlEncode:(NSString *)url;

+ (NSString *)urlDecode:(NSString *)url;

+ (NSString *)htmlEncode:(NSString *)string;

+ (NSString *)htmlDecode:(NSString *)string;

+ (NSString *)htmlToText:(NSString *)htmlString;


//MARK:数据加密

+ (NSString *)getMD5:(NSString *)string;

+ (NSString *)getMD5InMD5:(NSString *)string;

+ (NSString *)rsaEncryption:(NSString *)str prikey:(NSString *)key;
+ (NSString *)rsaDecryption:(NSString *)str pubkey:(NSString *)key;

+ (NSString *)rsaEncryption:(NSString *)str pubkey:(NSString *)key;
+ (NSString *)rsaDecryption:(NSString *)str prikey:(NSString *)key;


+ (NSString *)aesEncrption:(NSString *)str key:(NSString *)key;
+ (NSString *)aesDecryption:(NSString *)str key:(NSString *)key;

+ (NSString *)desEncrption:(NSString *)str key:(NSString *)key;
+ (NSString *)desDecryption:(NSString *)str key:(NSString *)key;

//MARK:扩展


/**
 通过身份证号码获取生日

 @param idCardNum 身份证号码
 @param yesOrNo 是否需要验证身份证号码
 @return 日期
 */
+ (NSDate *)getBirthDate:(NSString *)idCardNum cardNumVerify:(BOOL)yesOrNo;

/**
 通过身份证号码获取生日
 
 @param idCardNum 身份证号码
 @param yesOrNo 是否需要验证身份证号码
 @return 日期yyyy-MM-dd
 */
+ (NSString *)getBirthDateString:(NSString *)idCardNum cardNumVerify:(BOOL)yesOrNo;
/**
 *  汉字转拼音（含声调）
 */
+ (NSString *)pinyinFromMandrin:(NSString *)string;
/**
 *  汉字转拼音（不含声调）
 */
+ (NSString *)pinyinWithoutToneFromMandrin:(NSString *)string;
+ (NSAttributedString *)htmlDocumentTypeAttriStringFromHtmlString:(NSString *)htmlString;
///
+ (NSAttributedString *)highlightKeywordString:(NSString *)string keyword:(NSString *)keyword  originalAttrDict:(NSDictionary *)oDict highLighted:(NSDictionary *)hDict;
///根据身份证号码获取年龄 返回string
+ (NSString *)getAgeStrFromIDCardNum:(NSString *)idCard;
///通过身份证号码获取年龄 返回NSDateComponents
+ (NSDateComponents *)getAgeWithIDCardNum:(NSString *)idCard;

///计算文字所占尺寸
+ (CGSize)getTextSizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize;
///计算文字所占尺寸
+ (CGSize)getTextSizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize paragraph:(NSParagraphStyle *)paragraph;
@end
