//
//  ResourceDownloadOperation.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/23/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "ResourceDownloadOperation.h"
#import "MultipeerSessionManager.h"
#import "Track.h"
#import "Library.h"
#import "LibraryShareOperation.h"
#import "RigelAppContext.h"
#import "RigelErrorHandler.h"

@interface ResourceDownloadOperation () <MultipeerSessionManagerDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) Track *track;
@property (nonatomic, strong) Library *library;
@property (nonatomic, strong) MultipeerSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation ResourceDownloadOperation

- (instancetype)init {
    self = [self initWithSessionManager:nil track:nil library:nil];

    return self;
}

- (instancetype)initWithSessionManager:(MultipeerSessionManager *)sessionManager track:(Track *)track library:(Library *)library {
    if (self = [super init]) {
        if (!sessionManager || !track || !library) {
            [self failOperation];
            return nil;
        }

        _sessionManager = sessionManager;
        _track = track;
        _library = library;
    }

    return self;
}

- (void)main {
    if (!self.track) {
        [self failOperation];
        return;
    }

    if (self.track.isRemoteAvailable) {
        [self sendFileRequestMessageForTrack:self.track];
    }

    [self sendHTTPDownloadRequestForTrack:self.track];

    self.semaphore = dispatch_semaphore_create(0);
    dispatch_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (void)sendFileRequestMessageForTrack:(Track *)track {
    self.sessionManager.downloadDelegate = self;

    NSDictionary *trackRequestMessage = @{RigelRequestMessageKeyTitle:track.title, RigelRequestMessageKeyAction:RigelRequestMessageValueDownload};
    [self.sessionManager sendData:[NSKeyedArchiver archivedDataWithRootObject:trackRequestMessage]];
}

- (void)sendHTTPDownloadRequestForTrack:(Track *)track {
    NSString *stringURL = [RigelBaseURLString stringByAppendingString:[NSString stringWithFormat:@"%@.mp3", track.title]];
    stringURL = [stringURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *URL = [NSURL URLWithString:stringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];

    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];

    [task resume];

    self.session = session;
}

- (void)moveDownloadedFileFromURL:(NSURL *)location {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    NSString *newFilePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/downloads/%@.mp3", self.track.title]];
    NSURL *indexURL = [NSURL fileURLWithPath:newFilePath];
    // Removes file if already there
    if ([fileManager fileExistsAtPath:newFilePath]) {
        [fileManager removeItemAtURL:indexURL error:nil];
    }
    // Moves from temp location to known directory
    [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:newFilePath] error:&error];

    if (error) {
        [RigelErrorHandler handleError:[NSError errorWithDomain:RigelErrorDomain code:1009 userInfo:error.userInfo]];
    } else {
        [self updateTrackInLibrary];
        NSLog(@"DONE. Track file sucessfully downloaded and copied to dowloads folder.");
        self.success = YES;
    }

    dispatch_semaphore_signal(self.semaphore);
}

- (void)updateTrackInLibrary {
    [self.library updateTrack:self.track];

    self.data = self.library;
    LibraryShareOperation *shareOperation = [[LibraryShareOperation alloc] initWithSessionManager:self.sessionManager];
    shareOperation.queuePriority = NSQualityOfServiceUtility;
    [shareOperation addDependency:self];

    [[NSOperationQueue mainQueue] addOperation:shareOperation];
}

- (void)didStartReceivingResourceWithName:(NSString *)resourceName withProgress:(NSProgress *)progress {
    [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionInitial context:nil];
}

- (void)didReceiveResource:(NSString *)resourceName atURL:(NSURL *)localURL {
    NSLog(@"Finished receiving LOCAL track.");

    [self moveDownloadedFileFromURL:localURL];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Track LOCAL download progress %.2f", progress.fractionCompleted);
    }
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error) {
        [RigelErrorHandler handleError:error withCustomDescription:@"Track download failed"];

        dispatch_semaphore_signal(self.semaphore);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSLog(@"Finished receiving REMOTE track.");

    [self moveDownloadedFileFromURL:location];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (self.isCancelled) {
        [downloadTask cancel];
        [RigelErrorHandler handleError:[NSError errorWithDomain:RigelErrorDomain code:1001 userInfo:nil] withCustomDescription:@"Track download cancelled: Operation was cancelled"];
    }
    NSLog(@"Track REMOTE download progress %.2f", (double)totalBytesWritten/(double)totalBytesExpectedToWrite);
}

@end
