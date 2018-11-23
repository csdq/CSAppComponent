//
//  CSRSA.h
//  CSAppComponent
//  from https://github.com/ideawu/Objective-C-RSA
//  Created by mr.s on 2018/6/20.
//

#import <Foundation/Foundation.h>

@interface CSDataSecurity : NSObject

/**********RSA******************/
// return base64 encoded string
+ (NSString *)rsa_encryptString:(NSString *)str publicKey:(NSString *)pubKey;
// return raw data
+ (NSData *)rsa_encryptData:(NSData *)data publicKey:(NSString *)pubKey;
// return base64 encoded string
+ (NSString *)rsa_encryptString:(NSString *)str privateKey:(NSString *)privKey;
// return raw data
+ (NSData *)rsa_encryptData:(NSData *)data privateKey:(NSString *)privKey;

// decrypt base64 encoded string, convert result to string(not base64 encoded)
+ (NSString *)rsa_decryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSData *)rsa_decryptData:(NSData *)data publicKey:(NSString *)pubKey;
+ (NSString *)rsa_decryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSData *)rsa_decryptData:(NSData *)data privateKey:(NSString *)privKey;

/************AES*****************/
+ (NSString *)aes_encryptString:(NSString *)str password:(NSString *)passwd;
+ (NSData *)aes_encryptData:(NSData *)data password:(NSString *)passwd;
+ (NSString *)aes_decryptString:(NSString *)str password:(NSString *)passwd;
+ (NSData *)aes_decryptData:(NSData *)data password:(NSString *)passwd;

/************DES*****************/
+ (NSString *)des_encryptString:(NSString *)str password:(NSString *)passwd;
+ (NSData *)des_encryptData:(NSData *)data password:(NSString *)passwd;
+ (NSString *)des_decryptString:(NSString *)str password:(NSString *)passwd;
+ (NSData *)des_decryptData:(NSData *)data password:(NSString *)passwd;

/************MD5*****************/
+ (NSString *)md5:(NSString *)str;
@end
