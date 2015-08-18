//
//  XYDownloadManager.h
//  XYDownloadManager
//
//  Created by b5m on 15/8/13.
//  Copyright (c) 2015年 b5m.gzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^DownloadSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void(^DownloadFailBlock)(AFHTTPRequestOperation *opertion, NSError *error);
typedef void(^DownloadProgressBlock)(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead);

@interface XYDownloadManager : NSObject

+ (instancetype)sharedInstance;
- (NSOperation *)downloadFileWithUrlString:(NSString *)url
                                            catchName:(NSString *)fileName
                                             progress:(DownloadProgressBlock)progress
                                              success:(DownloadSuccessBlock)success
                                                 fail:(DownloadFailBlock)fail;
- (void)pauseWithOperation:(NSOperation *)operation;

@end
