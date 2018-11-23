//
//  CSRSA.m
//  CSAppComponent
//
//  Created by mr.s on 2018/6/20.
//

#import "CSDataSecurity.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import <Security/Security.h>

@implementation CSDataSecurity

static NSString *base64_encode(NSString *str){
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if(!data){
        return nil;
    }
    return base64_encode_data(data);
}

static NSString *base64_encode_data(NSData *data){
    data = [data base64EncodedDataWithOptions:0];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

static NSData *base64_decode(NSString *str){
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

//credit: http://hg.mozilla.org/services/fx-home/file/tip/Sources/NetworkAndStorage/CryptoUtils.m#l1036
+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key{
    // Skip ASN.1 private key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 22; //magic byte at offset 22
    
    if (0x04 != c_key[idx++]) return nil;
    
    //calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    } else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            //rsa length field longer than buffer
            return nil;
        }
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }
    
    // Now make a new NSData from this buffer
    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}

+ (SecKeyRef)addPublicKey:(NSString *)key{
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // This will be base64 encoded, decode it.
    NSData *data = base64_decode(key);
    data = [CSDataSecurity stripPublicKeyHeader:data];
    if(!data){
        return nil;
    }
    
    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PubKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
     kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return nil;
    }
    return keyRef;
}

+ (SecKeyRef)addPrivateKey:(NSString *)key{
    NSRange spos;
    NSRange epos;
    spos = [key rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    if(spos.length > 0){
        epos = [key rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    }else{
        spos = [key rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
        epos = [key rangeOfString:@"-----END PRIVATE KEY-----"];
    }
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // This will be base64 encoded, decode it.
    NSData *data = base64_decode(key);
    //    data = [CSDataSecurity stripPrivateKeyHeader:data];
    if(!data){
        return nil;
    }
    
    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PrivKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    [privateKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKey);
    
    // Add persistent version of the key to system keychain
    [privateKey setObject:data forKey:(__bridge id)kSecValueData];
    [privateKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)
     kSecAttrKeyClass];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return nil;
    }
    return keyRef;
}
#pragma mark - RSA
/* START: Encryption & Decryption with RSA private key */

+ (NSData *)rsa_encryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef isSign:(BOOL)isSign {
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        
        if (isSign) {
            status = SecKeyRawSign(keyRef,
                                   kSecPaddingPKCS1,
                                   srcbuf + idx,
                                   data_len,
                                   outbuf,
                                   &outlen
                                   );
        } else {
            status = SecKeyEncrypt(keyRef,
                                   kSecPaddingPKCS1,
                                   srcbuf + idx,
                                   data_len,
                                   outbuf,
                                   &outlen
                                   );
        }
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        }else{
            [ret appendBytes:outbuf length:outlen];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSString *)rsa_encryptString:(NSString *)str privateKey:(NSString *)privKey{
    NSData *data = [CSDataSecurity rsa_encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] privateKey:privKey];
    NSString *ret = base64_encode_data(data);
    return ret;
}

+ (NSData *)rsa_encryptData:(NSData *)data privateKey:(NSString *)privKey{
    if(!data || !privKey){
        return nil;
    }
    SecKeyRef keyRef = [CSDataSecurity addPrivateKey:privKey];
    if(!keyRef){
        return nil;
    }
    return [CSDataSecurity rsa_encryptData:data withKeyRef:keyRef isSign:YES];
}

+ (NSData *)rsa_decryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef,
                               kSecPaddingNone,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        }else{
            //the actual decrypted data is in the middle, locate it!
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for ( int i = 0; i < outlen; i++ ) {
                if ( outbuf[i] == 0 ) {
                    if ( idxFirstZero < 0 ) {
                        idxFirstZero = i;
                    } else {
                        idxNextZero = i;
                        break;
                    }
                }
            }
            
            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}


+ (NSString *)rsa_decryptString:(NSString *)str privateKey:(NSString *)privKey{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    data = [CSDataSecurity rsa_decryptData:data privateKey:privKey];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

+ (NSData *)rsa_decryptData:(NSData *)data privateKey:(NSString *)privKey{
    if(!data || !privKey){
        return nil;
    }
    SecKeyRef keyRef = [CSDataSecurity addPrivateKey:privKey];
    if(!keyRef){
        return nil;
    }
    return [CSDataSecurity rsa_decryptData:data withKeyRef:keyRef];
}

/* END: Encryption & Decryption with RSA private key */

/* START: Encryption & Decryption with RSA public key */

+ (NSString *)rsa_encryptString:(NSString *)str publicKey:(NSString *)pubKey{
    NSData *data = [CSDataSecurity rsa_encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
    NSString *ret = base64_encode_data(data);
    return ret;
}

+ (NSData *)rsa_encryptData:(NSData *)data publicKey:(NSString *)pubKey{
    if(!data || !pubKey){
        return nil;
    }
    SecKeyRef keyRef = [CSDataSecurity addPublicKey:pubKey];
    if(!keyRef){
        return nil;
    }
    return [CSDataSecurity rsa_encryptData:data withKeyRef:keyRef isSign:NO];
}

+ (NSString *)rsa_decryptString:(NSString *)str publicKey:(NSString *)pubKey{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    data = [CSDataSecurity rsa_decryptData:data publicKey:pubKey];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

+ (NSData *)rsa_decryptData:(NSData *)data publicKey:(NSString *)pubKey{
    if(!data || !pubKey){
        return nil;
    }
    SecKeyRef keyRef = [CSDataSecurity addPublicKey:pubKey];
    if(!keyRef){
        return nil;
    }
    return [CSDataSecurity rsa_decryptData:data withKeyRef:keyRef];
}

/* END: Encryption & Decryption with RSA public key */

#pragma mark - AES
+ (NSString *)aes_encryptString:(NSString *)str password:(NSString *)passwd{
    return base64_encode_data([self aesEncrption:str key:passwd]);
}

+ (NSData *)aes_encryptData:(NSData *)data password:(NSString *)passwd{
    return [self aesEncrption:base64_encode_data(data) key:passwd];
}

+ (NSString *)aes_decryptString:(NSString *)str password:(NSString *)passwd{
    return  [[NSString alloc] initWithData:[self aesDecryption:str key:passwd] encoding:NSUTF8StringEncoding] ;
}

+ (NSData *)aes_decryptData:(NSData *)data password:(NSString *)passwd{
    return [self aesDecryption:base64_encode_data(data) key:passwd];
}

+ (NSData *)AESKeyForPassword:(NSString *)password{
    NSMutableData *derivedKey = [NSMutableData dataWithLength:kCCKeySizeAES128];
    
    NSData *salt = [NSData dataWithBytes:saltBuff length:kCCKeySizeAES128];
    
    int result = CCKeyDerivationPBKDF(kCCPBKDF2,        // algorithm算法
                                      password.UTF8String,  // password密码
                                      password.length,      // passwordLength密码的长度
                                      salt.bytes,           // salt内容
                                      salt.length,          // saltLen长度
                                      kCCPRFHmacAlgSHA1,    // PRF
                                      kPBKDFRounds,         // rounds循环次数
                                      derivedKey.mutableBytes, // derivedKey
                                      derivedKey.length);   // derivedKeyLen derive:出自
    if(result!=kCCSuccess){
        
    }
    NSAssert(result == kCCSuccess,
             @"Unable to create AES key for spassword: %d", result);
    return derivedKey;
}

const NSUInteger kPBKDFRounds = 10000;  // ~80ms on an iPhone 4

static Byte saltBuff[] = {0,1,2,3,4,5,6,7,8,9,0xA,0xB,0xC,0xD,0xE,0xF};

static Byte ivBuff[]   = {0xA,1,0xB,5,4,0xF,7,9,0x17,3,1,6,8,0xC,0xD,91};

+ (NSData *)aesEncrption:(NSString *)plainText
                     key:(NSString *)key{
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    bzero(buffer, sizeof(buffer));
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,kCCOptionPKCS7Padding,
                                          [[self AESKeyForPassword:key] bytes], kCCKeySizeAES128,
                                          ivBuff /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return encryptData;
    }
    free(buffer);
    return nil;
}

+ (NSData *)aesDecryption:(NSString *)decryptedText
                      key:(NSString *)key{
    NSData *data = base64_decode(decryptedText);
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          [[self AESKeyForPassword:key] bytes], kCCKeySizeAES128,
                                          ivBuff ,/* initialization vector (optional) */
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *decryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        return decryptData;
    }
    free(buffer);
    return nil;
}

#pragma mark - DES
+ (NSString *)des_encryptString:(NSString *)str password:(NSString *)passwd{
    return base64_encode_data([self aesEncrption:str key:passwd]);
}

+ (NSData *)des_encryptData:(NSData *)data password:(NSString *)passwd{
    return [self desEncrption:base64_encode_data(data) key:passwd];
}

+ (NSString *)des_decryptString:(NSString *)str password:(NSString *)passwd{
    NSString * result = [[NSString alloc] initWithData:[self desDecryption:str key:passwd] encoding:NSUTF8StringEncoding];
    return result;
}

+ (NSData *)des_decryptData:(NSData *)data password:(NSString *)passwd{
    return [self desDecryption:base64_encode_data(data) key:passwd];
}

+ (NSData *)desEncrption:(NSString *)plainText
                     key:(NSString *)key{
    NSData * data = base64_decode(plainText);
    NSData * keyData = base64_decode(key);
    size_t numBytesEncrypted = 0;
    size_t bufferSize = data.length + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    
    CCCryptorStatus result = CCCrypt( kCCEncrypt, kCCAlgorithmDES, kCCOptionECBMode,
                                     keyData.bytes, kCCKeySizeDES,
                                     NULL,
                                     data.bytes, data.length,
                                     buffer, bufferSize,
                                     &numBytesEncrypted);
    NSData *output = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    free(buffer);
    if( result == kCCSuccess )
    {
        return output;
    } else {
        NSLog(@"Failed DES encrypt...");
        return nil;
    }
}

+ (NSData *)desDecryption:(NSString *)decryptedText
                      key:(NSString *)key{
    NSData * data = base64_decode(decryptedText);
    NSData * keyData = [key dataUsingEncoding:NSUTF8StringEncoding];//base64_decode(key);
    
    size_t numBytesEncrypted = 0;
    size_t bufferSize = data.length + kCCBlockSizeDES;
    void *buffer_decrypt = malloc(bufferSize);
    CCCryptorStatus result = CCCrypt( kCCDecrypt , kCCAlgorithmDES, kCCOptionECBMode,
                                     keyData.bytes, kCCKeySizeDES,
                                     NULL,
                                     data.bytes, data.length,
                                     buffer_decrypt, bufferSize,
                                     &numBytesEncrypted );
    
    NSData *output = [NSData dataWithBytes:buffer_decrypt length:numBytesEncrypted];
    free(buffer_decrypt);
    if( result == kCCSuccess )
    {
        return output;
    } else {
        NSLog(@"Failed DES decrypt ...");
        return nil;
    }
}


#pragma mark - MD5
+ (NSString *)md5:(NSString *)str{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
    
    //    const char *cStr = [str UTF8String];
    //    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    //
    //    NSString *MD5str = [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
    //                         result[0], result[1], result[2], result[3],
    //                         result[4], result[5], result[6], result[7],
    //                         result[8], result[9], result[10], result[11],
    //                         result[12], result[13], result[14], result[15]
    //                         ] lowercaseString];
    //    for (int i = 0; i < 16; i++) {
    //        result[i] = '\0';
    //    }
    //    return MD5str;
}

@end
