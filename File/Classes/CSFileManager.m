//
//  CSFileManager.m
//  CSAppComponent
//
//  Created by Mr.s on 2018/8/13.
//

#import "CSFileManager.h"
#import <CSAppComponent/CSDataTool.h>
#import <objc/runtime.h>
#import <sqlite3.h>
NSString * kCS_NOTIFCATION_FILE_DOWNLOAD_SUCCESS = @"kCS_NOTIFCATION_FILE_DOWNLOAD_SUCCESS";
NSString * kCS_NOTIFCATION_FILE_DOWNLOAD_FAILED = @"kCS_NOTIFCATION_FILE_DOWNLOAD_FAILED";
static NSString *CSFileErrorDomainName = @"CSFileErrorDomainName";
typedef enum : NSUInteger {
    CSFileErrorCodeOK = 0,
    CSFileErrorCodeURLNil = 1,
    CSFileErrorCodeDownloadFailed = 2,
    CSFileErrorCodeMoveFailed
} CSFileErrorCode;
static sqlite3 *database = nil;
static NSString *databasePath = nil;
static sqlite3_stmt *statement = nil;
@implementation CSFile
- (NSString *)fileId{
    if(_fileId == nil && self.source && self.source.absoluteString){
        _fileId = [CSDataTool getMD5:self.source.absoluteString];
    }
    return _fileId;
}

- (NSString *)reletivePath{
    if(_reletivePath == nil){
        if(self.absolutePath == nil){
            _reletivePath = [NSString stringWithFormat:@"/%@",self.fileName];
        }else{
            return @"";
        }
    }
    return _reletivePath;
}

- (NSDictionary *)fileAttribute{
//    NSFileCreationDate = "2018-08-13 09:38:36 +0000";
//    NSFileExtensionHidden = 0;
//    NSFileGroupOwnerAccountID = 20;
//    NSFileGroupOwnerAccountName = staff;
//    NSFileModificationDate = "2018-08-13 09:38:38 +0000";
//    NSFileOwnerAccountID = 502;
//    NSFilePosixPermissions = 384;
//    NSFileReferenceCount = 1;
//    NSFileSize = 47121;
//    NSFileSystemFileNumber = 12922136;
//    NSFileSystemNumber = 16777221;
//    NSFileType = NSFileTypeRegular;
    return [NSFileManager.defaultManager attributesOfItemAtPath:self.absolutePath error:nil];
}

- (NSNumber *)fileSize{
    return [self fileAttribute][@"NSFileSize"];
}

- (NSString *)fileSizeText{
//    Byte
    NSInteger byteSize = [self.fileSize integerValue];
    NSInteger KB = byteSize/1024;
    NSInteger MB = KB/1024;
    NSInteger GB = MB/1024;
    if(byteSize < 1024){
//        B
        return [NSString stringWithFormat:@"%ldBytes",byteSize];
    }else{
        if(KB < 1024){
            return [NSString stringWithFormat:@"%ldKB",KB];
        }else{
            if(MB < 1024){
                return [NSString stringWithFormat:@"%ld",MB];
            }else{
                return [NSString stringWithFormat:@"%ldGB",GB];
            }
        }
    }
}

- (NSString *)creationDate{
    return [self fileAttribute][@"NSFileCreationDate"];
}

- (NSString *)modicationDate{
    return [self fileAttribute][@"NSFileModificationDate"];
}

- (NSString *)fileName{
    if(_fileName == nil){
        _fileName = self.source.absoluteString.lastPathComponent;
    }
    return _fileName;
}

- (NSString *)extension{
    if(_extension == nil){
        _extension = [[self.fileName componentsSeparatedByString:@"."] lastObject];
    }
    return _extension;
}
@end

@interface CSFileManager()<NSURLSessionTaskDelegate>
{
    NSFileManager *_fileManager;
    sqlite3 *_database;
}
@property (nonatomic,strong) NSURLSession * session;
@property (nonatomic,strong) NSMutableDictionary * downloadModels;
@property (nonatomic,strong) NSMutableDictionary * progressBlocks;
@property (nonatomic,strong) NSMutableDictionary * finishBlocks;
@property (nonatomic,strong) NSMutableDictionary * errorBlocks;
@end

static CSFileManager *_manager;
@implementation CSFileManager
+ (instancetype)sharedInstance{
    if(_manager == nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _manager = [CSFileManager new];
            _manager.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:CSFileManager.sharedInstance delegateQueue:nil];
        });
    }
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloadModels = [NSMutableDictionary dictionary];
        self.progressBlocks = [NSMutableDictionary dictionary];
        self.finishBlocks = [NSMutableDictionary dictionary];
        self.errorBlocks = [NSMutableDictionary dictionary];
        self->_fileManager = [NSFileManager defaultManager];
        self.fileDirectory = [self applicationDocumentsDirectory];
        NSError *error = nil;
        [self->_fileManager createDirectoryAtPath:self.fileDirectory
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:&error];
        if(error){
            NSLog(@"%@",error);
        }
        
        if(![self createDB]){
            NSLog(@"File DB create failed");
        }
        
        NSLog(@"%@\n %@\n %@",databasePath,self.fileDirectory,[self applicationTmpDirectory]);
    }
    return self;
}
//MARK: download file
//下载文件
+ (void)downloadFile:(CSFile *)fileModel{
    [self downloadFile:fileModel progress:nil completed:nil failed:nil];
    
}

+ (void)downloadFile:(CSFile *)fileModel progress:(void (^)(CGFloat))progress{
    [self downloadFile:fileModel progress:progress completed:nil failed:nil];
}

+ (void)downloadFile:(CSFile *)fileModel
            progress:(void(^)(CGFloat percent))progress
           completed:(void(^)(CSFile *file))completed
              failed:(void(^)(NSError *error))failed{
    if(fileModel && fileModel.source){
        NSURLSession * session = CSFileManager.sharedInstance.session;
        NSURL *url = fileModel.source;
        [url setResourceValue:@(NO) forKey:NSURLIsExcludedFromBackupKey error:nil];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
        [CSFileManager.sharedInstance.downloadModels setObject:fileModel forKey:@(downloadTask.taskIdentifier)];
        [CSFileManager.sharedInstance.progressBlocks setObject:progress forKey:@(downloadTask.taskIdentifier)];
        if(completed){
            [CSFileManager.sharedInstance.finishBlocks setObject:completed forKey:@(downloadTask.taskIdentifier)];
        }
        if(failed){
            [CSFileManager.sharedInstance.errorBlocks setObject:failed forKey:@(downloadTask.taskIdentifier)];
        }

        [downloadTask resume];
    }else{
        NSError *error = [NSError errorWithDomain:CSFileErrorDomainName code:-1 userInfo:@{@"message":@"fielModel or source url is not correct"}];
        [NSNotificationCenter.defaultCenter postNotificationName:kCS_NOTIFCATION_FILE_DOWNLOAD_FAILED object:error];
        return;
    }
}

+ (void)cancelDownloadFile:(CSFile *)file{
    
}
//MARK: load file from other app
+ (void)loadFileFromOtherApp:(NSURL *)url{
    CSFile *fileModel = [CSFile new];
    fileModel.source = url;
    fileModel.fileName = url.lastPathComponent;
    fileModel.fileId = [CSDataTool getMD5:url.absoluteString];
    fileModel.reletivePath = [NSString stringWithFormat:@"%@/%@",fileModel.fileId,fileModel.fileName];
    NSError *error = nil;
    NSString *fileDir = [NSString stringWithFormat:@"%@/%@",CSFileManager.sharedInstance.fileDirectory,fileModel.fileId];
    [CSFileManager createDir:fileDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager moveItemAtURL:url toURL:[NSURL fileURLWithPath:fileModel.absolutePath] error:&error];
    if(error == nil){
        [CSFileManager.sharedInstance saveFile:fileModel];
    }else{
        [NSNotificationCenter.defaultCenter postNotificationName:kCS_NOTIFCATION_FILE_DOWNLOAD_FAILED object:error];
    }
}

////打开文件： 如果文件不在本地则下载
+ (void)openFile:(CSFile *)file{
    
}

+ (void)openFileWithURL:(NSURL *)url{
    
}
////
+ (NSArray<CSFile *> *)fetachAllFiles{
    return [CSFileManager.sharedInstance fetchAllFiles];
}
+ (CSFile *)fetachFileWithId:(NSString *)fileId{
    return [CSFileManager.sharedInstance fetchFileWithId:fileId];
}
////
+ (void)deleteAllFiles{
    [[CSFileManager fetachAllFiles] enumerateObjectsUsingBlock:^(CSFile * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
       [CSFileManager.sharedInstance->_fileManager removeItemAtPath:file.absolutePath error:nil];
        //移除父级文件夹
//        [CSFileManager.sharedInstance->_fileManager removeItemAtPath:file.absolutePath.stringByDeletingLastPathComponent error:nil];
    }];
    [CSFileManager.sharedInstance deleteAllFiles];
}
+ (void)deleteFile:(CSFile *)file{
    [CSFileManager.sharedInstance->_fileManager removeItemAtPath:file.absolutePath error:nil];
    //移除父级文件夹
//    [CSFileManager.sharedInstance->_fileManager removeItemAtPath:file.absolutePath.stringByDeletingLastPathComponent error:nil];
    [CSFileManager.sharedInstance deleteFile:file.fileId];
}

+ (BOOL)fileExists:(CSFile *)fileModel{
    return [CSFileManager.sharedInstance->_fileManager fileExistsAtPath:fileModel.absolutePath];
}
//MARK:
//MARK: DELEGATE
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error){
    CSFile *model = [CSFileManager.sharedInstance.downloadModels objectForKey:@(task.taskIdentifier)];
    NSString *message = error.localizedDescription==nil?@"网络错误":error.localizedDescription;
    [NSNotificationCenter.defaultCenter postNotificationName:kCS_NOTIFCATION_FILE_DOWNLOAD_SUCCESS object:nil userInfo:@{@"code":@(CSFileErrorCodeDownloadFailed),@"message":message,@"fileUuid":model.fileId}];
        void(^failedBlock)(NSError *error) = self.errorBlocks[@(task.taskIdentifier)];
        if(failedBlock){
            failedBlock(error);
        }
    }
    [CSFileManager.sharedInstance.downloadModels removeObjectForKey:@(task.taskIdentifier)];
    [CSFileManager.sharedInstance.errorBlocks removeObjectForKey:@(task.taskIdentifier)];
    [CSFileManager.sharedInstance.finishBlocks removeObjectForKey:@(task.taskIdentifier)];
    [CSFileManager.sharedInstance.progressBlocks removeObjectForKey:@(task.taskIdentifier)];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    CSFile *model = [CSFileManager.sharedInstance.downloadModels objectForKey:@(downloadTask.taskIdentifier)];
    if(model==nil||model.fileId==nil){
        //TODO:
        //kOA_POST_NOTIFICATION(kOA_NOTIFICATION_FILE_DOWNLOAD, ([NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"code",@"文件id为空",@"message",model.fileUuid,@"fileUuid",model.fileName,@"fileName",nil]))
    }
    NSLog(@"下载完成");
    NSInteger statusCode = ((NSHTTPURLResponse *)downloadTask.response).statusCode;
    BOOL success = NO;
    switch (statusCode) {
        case 200:
        {
            success = YES;
        }
            break;
        case 404:
        {
            /*置空，可重复下载多次，用来提醒用户*/
            //                    [CSFileManager.sharedInstance.dataDict removeObjectForKey:model.fileId];
        }
            break;
        default:
        {
            /*置空，可重复下载多次，用来提醒用户*/
            //                    [CSFileManager.sharedInstance.dataDict removeObjectForKey:model.fileId];
        }
            break;
    }
    if(!success){
        [NSNotificationCenter.defaultCenter postNotificationName:kCS_NOTIFCATION_FILE_DOWNLOAD_FAILED object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(CSFileErrorCodeDownloadFailed),@"code",@"下载错误",@"message",model.fileId,@"fileUuid",model.fileName,@"fileName",nil]];
        void(^failedBlock)(NSError *error) = self.errorBlocks[@(downloadTask.taskIdentifier)];
        if(failedBlock){
            //TODO: 下载错误信息
            failedBlock([NSError errorWithDomain:CSFileErrorDomainName code:CSFileErrorCodeDownloadFailed userInfo:@{}]);
        }
    }else{
//        NSMutableString *filePath = [NSMutableString stringWithFormat:@"%@/%@/",CSFileManager.sharedInstance.fileDirectory,model.fileId];
//        NSError *error = nil;
//        [CSFileManager createDir:filePath];
//        [filePath appendString:model.fileName];
        NSMutableString *filePath = [NSMutableString stringWithFormat:@"%@/%@",CSFileManager.sharedInstance.fileDirectory,model.fileName];
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:filePath]){
            [fileManager removeItemAtPath:filePath error:nil];
        }
        
        [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:&error];
        if(error){
            NSString *message = error.localizedDescription==nil?@"文件移动失败":error.localizedDescription;
            [NSNotificationCenter.defaultCenter postNotificationName:kCS_NOTIFCATION_FILE_DOWNLOAD_SUCCESS object:nil userInfo:@{@"code":@(CSFileErrorCodeMoveFailed),@"message":message,@"fileId":model.fileId}];
            void(^failedBlock)(NSError *error) = self.errorBlocks[@(downloadTask.taskIdentifier)];
            if(failedBlock){
                failedBlock(error);
            }
        }else{
            model.absolutePath = filePath;
            model.reletivePath = [NSString stringWithFormat:@"/%@",model.fileName];
            [CSFileManager.sharedInstance saveFile:model];
            [NSNotificationCenter.defaultCenter postNotificationName:kCS_NOTIFCATION_FILE_DOWNLOAD_SUCCESS object:nil userInfo:@{@"code":@(CSFileErrorCodeOK),@"filePath":filePath,@"fileId":model.fileId,@"fileName":model.fileName}];
            void(^finish)(CSFile *file) = self.finishBlocks[@(downloadTask.taskIdentifier)];
            if(finish){
                finish(model);
            }
        }
    }
    [CSFileManager.sharedInstance.downloadModels removeObjectForKey:@(downloadTask.taskIdentifier)];
    [CSFileManager.sharedInstance.errorBlocks removeObjectForKey:@(downloadTask.taskIdentifier)];
    [CSFileManager.sharedInstance.finishBlocks removeObjectForKey:@(downloadTask.taskIdentifier)];
    [CSFileManager.sharedInstance.progressBlocks removeObjectForKey:@(downloadTask.taskIdentifier)];
    [self.progressBlocks removeObjectForKey:@(downloadTask.taskIdentifier)];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    void(^progress)(CGFloat percent) = self.progressBlocks[@(downloadTask.taskIdentifier)];
    progress(1.0 * totalBytesWritten/totalBytesExpectedToWrite);
}

//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
// didResumeAtOffset:(int64_t)fileOffset
//expectedTotalBytes:(int64_t)expectedTotalBytes{
//    void(^progress)(CGFloat percent) = self.progressBlocks[@(downloadTask.taskIdentifier)];
//    progress(1.0 * fileOffset/expectedTotalBytes);
//    NSLog(@"2222    %lld---%lld---%f",fileOffset,expectedTotalBytes,1.0 * fileOffset/expectedTotalBytes);
//}
//MARK: Data Storage
- (BOOL)createDB{
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    databasePath = [arr firstObject];
    databasePath = [databasePath stringByAppendingPathComponent:@"com.csdq.file"];
    if(![self->_fileManager fileExistsAtPath:databasePath]){
        [CSFileManager createDir:databasePath];
    }
    databasePath = [databasePath stringByAppendingPathComponent:@"File.sqlite"];
    BOOL result = NO;
    if ([self->_fileManager fileExistsAtPath:databasePath] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS FILE (id INTEGER PRIMARY KEY AUTOINCREMENT, fileId text, fileName text , reletivePath text , source text)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                result = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
        } else {
            result = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return result;
}

- (BOOL)saveFile:(CSFile *)file{
    const char *dbpath = [databasePath UTF8String];
    BOOL result;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO File (fileId, fileName, reletivePath, source) values(\"%@\",\"%@\", \"%@\", \"%@\")",file.fileId,file.fileName,file.reletivePath,file.source];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            result = YES;
        } else {
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }else{
        result = NO;
    }
    return result;
}

- (NSArray *)fetchAllFiles{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = @"SELECT fileId, fileName , relativePath, source from File";
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                CSFile *file = [CSFile new];
                file.fileId = [[NSString alloc] initWithUTF8String:
                               (const char *) sqlite3_column_text(statement, 0)];
                file.fileName = [[NSString alloc] initWithUTF8String:
                                 (const char *) sqlite3_column_text(statement, 1)];
                file.extension = [[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 2)];
                file.reletivePath = [[NSString alloc]initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 3)];
                file.source = [NSURL URLWithString:[[NSString alloc]initWithUTF8String:
                                                    (const char *) sqlite3_column_text(statement, 4)]];
                [resultArray addObject:file];
            } else {
                NSLog(@"Not found");
                return nil;
            }
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return resultArray;
}

- (CSFile *)fetchFileWithId:(NSString *)fileId{
    CSFile *file = nil;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT fileId, fileName , relativePath, source from File WHERE fileId = \"%@\"",fileId];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                file = [CSFile new];
                file.fileId = [[NSString alloc] initWithUTF8String:
                               (const char *) sqlite3_column_text(statement, 0)];
                file.fileName = [[NSString alloc] initWithUTF8String:
                                 (const char *) sqlite3_column_text(statement, 1)];
                file.extension = [[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 2)];
                file.reletivePath = [[NSString alloc]initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 3)];
                file.source = [NSURL URLWithString:[[NSString alloc]initWithUTF8String:
                                                    (const char *) sqlite3_column_text(statement, 4)]];
            } else {
                NSLog(@"Not found");
                return nil;
            }
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return file;
}

- (BOOL)deleteFile:(NSString *)fileId{
    BOOL result;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM FILE WHERE fileId = \"%@\"",fileId];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            if (sqlite3_exec(database, query_stmt, NULL, NULL, &errMsg) == SQLITE_OK) {
                result = YES;
            }else{
                result = NO;
            }
            sqlite3_close(database);
        }else{
            result = NO;
        }
    }else{
        result = NO;
        NSLog(@"数据打开失败");
    }
    return result;
}

- (BOOL)deleteAllFiles{
    BOOL result;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = @"DELETE FROM FILE";
        const char *query_stmt = [querySQL UTF8String];
        char *errMsg;
        if (sqlite3_exec(database, query_stmt, NULL, NULL, &errMsg) == SQLITE_OK) {
            result = YES;
        }else{
            result = NO;
        }
        sqlite3_close(database);
    }else{
        result = NO;
        NSLog(@"数据打开失败");
    }
    return result;
}
#pragma mark - File system support

- (NSString *)applicationDocumentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)applicationTmpDirectory{
    return NSTemporaryDirectory();
}

+ (void)createDir:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]){
        [fileManager createDirectoryAtPath:filePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
}

- (NSString *)saveTmpImgFromSys:(UIImage *)img fileName:(NSString *)name{
    return [self saveImgFromSys:img fileName:name inDir:[self applicationTmpDirectory]];
}

- (NSString *)saveImgFromSys:(UIImage *)img fileName:(NSString *)name{
    return [self saveImgFromSys:img fileName:name inDir:self.fileDirectory];
}

- (NSString *)saveImgFromSys:(UIImage *)img fileName:(NSString *)name inDir:(NSString *)dir{
    NSData *imgData = UIImageJPEGRepresentation(img,0.5);
    if (imgData.length > 1024*1024) {
        imgData =  UIImageJPEGRepresentation(img, imgData.length / (1024*1024*8.0f));
    }
    if(imgData!=nil){
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",dir,name];
        if([imgData writeToFile:filePath atomically:YES]){
            return filePath;
        }else{
            return nil;
        }
    }
    return nil;
}

+ (NSDictionary *)mimeTypeDict{
    
    return @{@"evy":@"application/envoy",
             @"fif":@"application/fractals",
             @"spl":@"application/futuresplash",
             @"hta":@"application/hta",
             @"acx":@"application/internet-property-stream",
             @"hqx":@"application/mac-binhex40",
             @"doc":@"application/msword",
             @"dot":@"application/msword",
             @"*":@"application/octet-stream",
             @"bin":@"application/octet-stream",
             @"class":@"application/octet-stream",
             @"dms":@"application/octet-stream",
             @"exe":@"application/octet-stream",
             @"lha":@"application/octet-stream",
             @"lzh":@"application/octet-stream",
             @"oda":@"application/oda",
             @"axs":@"application/olescript",
             @"pdf":@"application/pdf",
             @"prf":@"application/pics-rules",
             @"p10":@"application/pkcs10",
             @"crl":@"application/pkix-crl",
             @"ai":@"application/postscript",
             @"eps":@"application/postscript",
             @"ps":@"application/postscript",
             @"rtf":@"application/rtf",
             @"setpay":@"application/set-payment-initiation",
             @"setreg":@"application/set-registration-initiation",
             @"xla":@"application/vnd.ms-excel",
             @"xlc":@"application/vnd.ms-excel",
             @"xlm":@"application/vnd.ms-excel",
             @"xls":@"application/vnd.ms-excel",
             @"xlt":@"application/vnd.ms-excel",
             @"xlw":@"application/vnd.ms-excel",
             @"msg":@"application/vnd.ms-outlook",
             @"sst":@"application/vnd.ms-pkicertstore",
             @"cat":@"application/vnd.ms-pkiseccat",
             @"stl":@"application/vnd.ms-pkistl",
             @"pot":@"application/vnd.ms-powerpoint",
             @"pps":@"application/vnd.ms-powerpoint",
             @"ppt":@"application/vnd.ms-powerpoint",
             @"mpp":@"application/vnd.ms-project",
             @"wcm":@"application/vnd.ms-works",
             @"wdb":@"application/vnd.ms-works",
             @"wks":@"application/vnd.ms-works",
             @"wps":@"application/vnd.ms-works",
             @"hlp":@"application/winhlp",
             @"bcpio":@"application/x-bcpio",
             @"cdf":@"application/x-cdf",
             @"z":@"application/x-compress",
             @"tgz":@"application/x-compressed",
             @"cpio":@"application/x-cpio",
             @"csh":@"application/x-csh",
             @"dcr":@"application/x-director",
             @"dir":@"application/x-director",
             @"dxr":@"application/x-director",
             @"dvi":@"application/x-dvi",
             @"gtar":@"application/x-gtar",
             @"gz":@"application/x-gzip",
             @"hdf":@"application/x-hdf",
             @"ins":@"application/x-internet-signup",
             @"isp":@"application/x-internet-signup",
             @"iii":@"application/x-iphone",
             @"js":@"application/x-javascript",
             @"latex":@"application/x-latex",
             @"mdb":@"application/x-msaccess",
             @"crd":@"application/x-mscardfile",
             @"clp":@"application/x-msclip",
             @"dll":@"application/x-msdownload",
             @"m13":@"application/x-msmediaview",
             @"m14":@"application/x-msmediaview",
             @"mvb":@"application/x-msmediaview",
             @"wmf":@"application/x-msmetafile",
             @"mny":@"application/x-msmoney",
             @"pub":@"application/x-mspublisher",
             @"scd":@"application/x-msschedule",
             @"trm":@"application/x-msterminal",
             @"wri":@"application/x-mswrite",
             @"cdf":@"application/x-netcdf",
             @"nc":@"application/x-netcdf",
             @"pma":@"application/x-perfmon",
             @"pmc":@"application/x-perfmon",
             @"pml":@"application/x-perfmon",
             @"pmr":@"application/x-perfmon",
             @"pmw":@"application/x-perfmon",
             @"p12":@"application/x-pkcs12",
             @"pfx":@"application/x-pkcs12",
             @"p7b":@"application/x-pkcs7-certificates",
             @"spc":@"application/x-pkcs7-certificates",
             @"p7r":@"application/x-pkcs7-certreqresp",
             @"p7c":@"application/x-pkcs7-mime",
             @"p7m":@"application/x-pkcs7-mime",
             @"p7s":@"application/x-pkcs7-signature",
             @"sh":@"application/x-sh",
             @"shar":@"application/x-shar",
             @"swf":@"application/x-shockwave-flash",
             @"sit":@"application/x-stuffit",
             @"sv4cpio":@"application/x-sv4cpio",
             @"sv4crc":@"application/x-sv4crc",
             @"tar":@"application/x-tar",
             @"tcl":@"application/x-tcl",
             @"tex":@"application/x-tex",
             @"texi":@"application/x-texinfo",
             @"texinfo":@"application/x-texinfo",
             @"roff":@"application/x-troff",
             @"t":@"application/x-troff",
             @"tr":@"application/x-troff",
             @"man":@"application/x-troff-man",
             @"me":@"application/x-troff-me",
             @"ms":@"application/x-troff-ms",
             @"ustar":@"application/x-ustar",
             @"src":@"application/x-wais-source",
             @"cer":@"application/x-x509-ca-cert",
             @"crt":@"application/x-x509-ca-cert",
             @"der":@"application/x-x509-ca-cert",
             @"pko":@"application/ynd.ms-pkipko",
             @"zip":@"application/zip",
             @"au":@"audio/basic",
             @"snd":@"audio/basic",
             @"mid":@"audio/mid",
             @"rmi":@"audio/mid",
             @"mp3":@"audio/mpeg",
             @"aif":@"audio/x-aiff",
             @"aifc":@"audio/x-aiff",
             @"aiff":@"audio/x-aiff",
             @"m3u":@"audio/x-mpegurl",
             @"ra":@"audio/x-pn-realaudio",
             @"ram":@"audio/x-pn-realaudio",
             @"wav":@"audio/x-wav",
             @"bmp":@"image/bmp",
             @"cod":@"image/cis-cod",
             @"gif":@"image/gif",
             @"ief":@"image/ief",
             @"jpe":@"image/jpeg",
             @"jpeg":@"image/jpeg",
             @"jpg":@"image/jpeg",
             @"jfif":@"image/pipeg",
             @"svg":@"image/svg+xml",
             @"tif":@"image/tiff",
             @"tiff":@"image/tiff",
             @"ras":@"image/x-cmu-raster",
             @"cmx":@"image/x-cmx",
             @"ico":@"image/x-icon",
             @"pnm":@"image/x-portable-anymap",
             @"pbm":@"image/x-portable-bitmap",
             @"pgm":@"image/x-portable-graymap",
             @"ppm":@"image/x-portable-pixmap",
             @"rgb":@"image/x-rgb",
             @"xbm":@"image/x-xbitmap",
             @"xpm":@"image/x-xpixmap",
             @"xwd":@"image/x-xwindowdump",
             @"mht":@"message/rfc822",
             @"mhtml":@"message/rfc822",
             @"nws":@"message/rfc822",
             @"css":@"text/css",
             @"323":@"text/h323",
             @"htm":@"text/html",
             @"html":@"text/html",
             @"stm":@"text/html",
             @"uls":@"text/iuls",
             @"bas":@"text/plain",
             @"c":@"text/plain",
             @"h":@"text/plain",
             @"txt":@"text/plain",
             @"rtx":@"text/richtext",
             @"sct":@"text/scriptlet",
             @"tsv":@"text/tab-separated-values",
             @"htt":@"text/webviewhtml",
             @"htc":@"text/x-component",
             @"etx":@"text/x-setext",
             @"vcf":@"text/x-vcard",
             @"mp2":@"video/mpeg",
             @"mpa":@"video/mpeg",
             @"mpe":@"video/mpeg",
             @"mpeg":@"video/mpeg",
             @"mpg":@"video/mpeg",
             @"mpv2":@"video/mpeg",
             @"mov":@"video/quicktime",
             @"qt":@"video/quicktime",
             @"lsf":@"video/x-la-asf",
             @"lsx":@"video/x-la-asf",
             @"asf":@"video/x-ms-asf",
             @"asr":@"video/x-ms-asf",
             @"asx":@"video/x-ms-asf",
             @"avi":@"video/x-msvideo",
             @"movie":@"video/x-sgi-movie",
             @"flr":@"x-world/x-vrml",
             @"vrml":@"x-world/x-vrml",
             @"wrl":@"x-world/x-vrml",
             @"wrz":@"x-world/x-vrml",
             @"xaf":@"x-world/x-vrml",
             @"xof":@"x-world/x-vrml",
             };
}
@end
