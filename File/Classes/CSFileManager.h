//
//  CSFileManager.h
//  CSAppComponent
//
//  Created by Mr.s on 2018/8/13.
//

#import <Foundation/Foundation.h>
#import <CSDataModel/CSDataModel.h>
extern NSString * kCS_NOTIFCATION_FILE_DOWNLOAD_SUCCESS;
extern NSString * kCS_NOTIFCATION_FILE_DOWNLOAD_FAILED;
@interface CSFile: CSBaseModel
//文件ID
@property (nonatomic,strong) NSString * fileId;
//文件名
@property (nonatomic,strong) NSString * fileName;
//绝对路径
@property (nonatomic,strong) NSString * absolutePath;
//文件大小
@property (nonatomic,strong) NSNumber * fileSize;
//文件大小 带单位
@property (nonatomic,strong) NSString * fileSizeText;
//创建日期
@property (nonatomic,strong) NSString * creationDate;
//上一次修改日期
@property (nonatomic,strong) NSString * modicationDate;
//文件扩展名
@property (nonatomic,strong) NSString * extension;
//相对路径 相对于fileDirectory路径
@property (nonatomic,strong) NSString * reletivePath;
//来源
@property (nonatomic,strong) NSURL * source;
@end


@interface CSFileManager : NSObject
@property (nonatomic,strong) NSString * fileDirectory;
+ (instancetype)sharedInstance;
//下载文件
+ (void)downloadFile:(CSFile *)fileModel;
+ (void)downloadFile:(CSFile *)fileModel
            progress:(void(^)(CGFloat percent))progress;
+ (void)downloadFile:(CSFile *)fileModel
            progress:(void(^)(CGFloat percent))progress
           completed:(void(^)(CSFile *file))completed
              failed:(void(^)(NSError *error))failed;
+ (void)cancelDownloadFile:(CSFile *)file;
//上传文件
+ (void)uploadFile:(NSData *)data
          toServer:(NSURL *)url
          progress:(void(^)(CGFloat percent))progress
            forKey:(NSString *)key
         completed:(void(^)(CSFile *file))completed
            failed:(void(^)(NSError *error))failed;
//打开文件： 如果文件不在本地则下载
+ (void)openFile:(CSFile *)file;
+ (void)openFileWithURL:(NSURL *)url;
//
+ (NSArray<CSFile *> *)fetachAllFiles;
+ (CSFile *)fetachFileWithId:(NSString *)fileId;
//
+ (void)deleteAllFiles;
+ (void)deleteFile:(CSFile *)file;
//
+ (BOOL)fileExists:(CSFile *)fileModel;
@end
