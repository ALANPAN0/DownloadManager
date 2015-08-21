//
//  XYDownloadManager.m
//  XYDownloadManager
//
//  Created by b5m on 15/8/13.
//  Copyright (c) 2015年 b5m.gzy. All rights reserved.
//

#import "XYDownloadManager.h"
#import "AFNetworking.h"

static NSString *const kCacheComponent = @"XYDownload";
static NSString *const kOperation = @"operation";
static NSString *const kFileName = @"fileName";

@interface XYDownloadManager ()

@property (nonatomic, strong) NSMutableArray *operations;
@property (nonatomic, strong) NSMutableArray *completedOpreations;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@property (nonatomic, assign) AFNetworkReachabilityStatus reachAbilityStatus;

@end

@implementation XYDownloadManager

#pragma mark - private method

static NSString * catchPath() {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    NSString *catchPath = [documentPath stringByAppendingPathComponent:kCacheComponent];
    BOOL isDir = NO;
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL isExist = [fileManger fileExistsAtPath:catchPath isDirectory:&isDir];
    if (!(isDir && isExist)) {
        [fileManger createDirectoryAtPath:catchPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return catchPath;
}

- (AFNetworkReachabilityManager *)reachabilityManager {
    if (!_reachabilityManager) {
        _reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    }
    return _reachabilityManager;
}


- (NSMutableArray *)operations {
    if (!_operations) {
        _operations = [NSMutableArray array];
    }
    return _operations;
}

- (unsigned long long)fileSizeOfPath:(NSString *)path {
    unsigned long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSAssert(NO, @"file is not exist at patch!");
    }
    NSError *error = nil;
    //return some attributes of files
    NSDictionary *attribute = [fileManager attributesOfItemAtPath:path error:&error];
    if (attribute && !error) {
        fileSize = [attribute fileSize];
    }
    
    return fileSize;
}

#pragma mark - public method

+ (instancetype)sharedInstance {
    static XYDownloadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance.reachabilityManager startMonitoring];
        [sharedInstance.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            sharedInstance.reachAbilityStatus = status;
            if (status == AFNetworkReachabilityStatusNotReachable) {
                NSLog(@"AFNetworkReachabilityStatusNotReachable!");
                
                for (NSDictionary *operation in sharedInstance.operations) {
                    
                    [(AFHTTPRequestOperation *)operation[kOperation] pause];
                    [(AFHTTPRequestOperation *)operation[kOperation] cancel];
                }
            }
        }];
    });
    return sharedInstance;
}

- (NSOperation *)downloadFileWithUrlString:(NSString *)url
                                            catchName:(NSString *)fileName
                                             progress:(DownloadProgressBlock)progress
                                              success:(DownloadSuccessBlock)success
                                                 fail:(DownloadFailBlock)fail {
    if (!fileName.length) {
        NSAssert(NO, @"fileName is nil!");
    }
    
    NSString *filePath = [catchPath() stringByAppendingPathComponent:fileName];

    BOOL opreationIsExist = NO;
    for (NSDictionary *operation in _operations) {
        if ([operation[kFileName] isEqualToString:fileName]) {
            opreationIsExist = YES;
            break;
        }
    }
    
    if (opreationIsExist) {
        for (NSDictionary *operation in _operations) {
            
            if ([operation[kFileName] isEqualToString:fileName]) {
                if ([(AFHTTPRequestOperation *)operation[kOperation] isPaused]) {
                    [(AFHTTPRequestOperation *)operation[kOperation] cancel];
                    [_operations removeObject:operation];
                    break;
                }else {
                    return (AFHTTPRequestOperation *)operation[kOperation];
                }
            }
        }
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    unsigned long long downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        downloadedBytes = [self fileSizeOfPath:filePath];
        if (downloadedBytes > 0) {
            NSMutableURLRequest *mutableRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableRequest;
        }
    }
    
    //do not use the cache, avoid breakpoint continued spread
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSDictionary *dict = @{kFileName:fileName,
                           kOperation:operation};
    [self.operations addObject:dict];
    
    //download patch
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];

    //progress block
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
       CGFloat schedule = ((CGFloat)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
        
       progress(schedule, (totalBytesRead + downloadedBytes) / 1024 / 1024.0f,(totalBytesExpectedToRead + downloadedBytes) / 1024 / 1024.0f);
    }];
    
    //success or fail block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(operation, error);
    }];

    [operation start];
    return operation;
}

- (void)pauseWithOperation:(NSOperation *)operation {
    [(AFHTTPRequestOperation *)operation pause];
}



@end
