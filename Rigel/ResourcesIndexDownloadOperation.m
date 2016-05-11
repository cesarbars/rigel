//
//  ResourcesIndexDownloadOperation.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/11/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "ResourcesIndexDownloadOperation.h"

#import "MultipeerSessionManager.h"
#import "RigelErrorHandler.h"

@interface ResourcesIndexDownloadOperation () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURL *resourcesURL;
@property (nonatomic, strong) MultipeerSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ResourcesIndexDownloadOperation

- (instancetype)init {
    self = [self initWithResourcesIndexURL:nil sessionManager:nil];
    return self;
}

- (instancetype)initWithResourcesIndexURL:(NSURL *)resourcesURL sessionManager:(MultipeerSessionManager *)sessionManager {
    if (self = [super init]) {
        _resourcesURL = resourcesURL;
        _sessionManager = sessionManager;
    }

    return self;
}

- (void)main {
    if (self.isCancelled) {
        return;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:self.resourcesURL];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];

    [task resume];

    self.session = session;
}

- (void)dealloc {
    [_session invalidateAndCancel];
    _session = nil;
    _sessionManager = nil;
    _resourcesURL = nil;
}

#pragma mark NSURLSessionDataDelegate

-(void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error) {
        [RigelErrorHandler handleError:error withCustomDescription:@"Index resources plist download failed"];
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSLog(@"Index file sucessfully downloaded at location %@", location);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (self.isCancelled) {
        [downloadTask cancel];
        [RigelErrorHandler handleError:[NSError errorWithDomain:@"com.cesarbars.rigel" code:1001 userInfo:nil] withCustomDescription:@"Index download cancelled: Operation was cancelled"];
    }
    NSLog(@"Index download progress %f", (double)totalBytesWritten/(double)totalBytesExpectedToWrite);
}

@end
