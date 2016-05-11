//
//  PopulateResourcesIndexOperation.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/11/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "PopulateResourcesIndexOperation.h"

#import "MultipeerSessionManager.h"
#import "RigelErrorHandler.h"

@interface PopulateResourcesIndexOperation () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURL *resourcesURL;
@property (nonatomic, strong) MultipeerSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation PopulateResourcesIndexOperation

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
    NSLog(@"Index download progress %f", (double)totalBytesWritten/(double)totalBytesExpectedToWrite);
}

@end
