//
//  ResourcesIndexDownloadOperation.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/11/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "ResourcesIndexDownloadOperation.h"

#import "RigelErrorHandler.h"

@interface ResourcesIndexDownloadOperation () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURL *resourcesURL;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation ResourcesIndexDownloadOperation

- (instancetype)init {
    self = [self initWithResourcesIndexURL:nil];
    return self;
}

- (instancetype)initWithResourcesIndexURL:(NSURL *)resourcesURL {
    if (self = [super init]) {
        _resourcesURL = resourcesURL;
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

    self.semaphore = dispatch_semaphore_create(0);
    dispatch_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (void)dealloc {
    [_session invalidateAndCancel];
    _session = nil;
    _resourcesURL = nil;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error) {
        [RigelErrorHandler handleError:error withCustomDescription:@"Index resources plist download failed"];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *folder = [documentsPath stringByAppendingPathComponent:@"downloads/index/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    if (![fileManager fileExistsAtPath:folder]){
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
    }    

    if (!error) {
        NSString *newFilePath = [folder stringByAppendingPathComponent:@"index.plist"];
        NSURL *indexURL = [NSURL fileURLWithPath:newFilePath];
        // Removes file if already there
        if ([fileManager fileExistsAtPath:newFilePath]) {
            [fileManager removeItemAtURL:indexURL error:nil];
        }
        // Moves from temp location to known directory
        [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:newFilePath] error:&error];

    }

    if (error) {
        [RigelErrorHandler handleError:[NSError errorWithDomain:RigelErrorDomain code:1001 userInfo:error.userInfo]];
    }

    NSLog(@"Index file sucessfully downloaded and copied to dowloads folder.");

    self.success = YES;

    dispatch_semaphore_signal(self.semaphore);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (self.isCancelled) {
        [downloadTask cancel];
        [RigelErrorHandler handleError:[NSError errorWithDomain:@"com.cesarbars.rigel" code:1001 userInfo:nil] withCustomDescription:@"Index download cancelled: Operation was cancelled"];
    }
    NSLog(@"Index download progress %f", (double)totalBytesWritten/(double)totalBytesExpectedToWrite);
}

@end
