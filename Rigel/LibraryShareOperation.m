//
//  LibraryShareOperaion.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "LibraryShareOperation.h"
#import "Library.h"
#import "Track.h"
#import "RigelErrorHandler.h"

#import "MultipeerSessionManager.h"

@interface LibraryShareOperation ()

@property (nonatomic, strong) MultipeerSessionManager *sessionManager;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation LibraryShareOperation

- (instancetype)init {
    self = [self initWithSessionManager:nil];

    return self;
}

- (instancetype)initWithSessionManager:(MultipeerSessionManager *)sessionManager {
    if (self = [super init]) {
        _sessionManager = sessionManager;
    }

    return self;
}

- (void)main {
    RigelOperation *lastDependency = (RigelOperation *)self.dependencies.lastObject;
    if (!lastDependency.success) {
        [self failOperation];
        return;
    }

    Library *library = nil;
    if ([lastDependency.data isKindOfClass:[Library class]]) {
        library = (Library *)lastDependency.data;
        self.data = library;
    } else {
        [self failOperation];
        return;
    }

    NSArray *localTracksRepresentation = nil;
    if (library) {
        localTracksRepresentation = [self localTracksRepresentationArrayFromLibrary:library];
    }

    NSString *archivePath = nil;
    if (localTracksRepresentation) {
        archivePath = [self archiveTracksRepresentation:localTracksRepresentation];
    }

    if (archivePath) {
        self.semaphore = dispatch_semaphore_create(0);
        [self shareTracksRepresentationFromPath:archivePath];
        dispatch_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }
}

- (NSArray *)localTracksRepresentationArrayFromLibrary:(Library *)library {
    NSArray *allTracks = [library allTracks];

    NSMutableArray *localTracks = [[NSMutableArray alloc] init];

    for (Track *track in allTracks) {
        if (track.isLocal) {
            [localTracks addObject:track];
        }
    }

    if (localTracks.count == 0) {
        return @[];
    }

    NSMutableArray *localTracksRepresentationArray = [[NSMutableArray alloc] init];

    for (Track *track in localTracks) {
        NSDictionary *trackRepresentation = @{@"title":track.title};
        [localTracksRepresentationArray addObject:trackRepresentation];
    }

    return [localTracksRepresentationArray copy];
}

- (NSString *)archiveTracksRepresentation:(NSArray *)representation {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *folder = [documentsPath stringByAppendingPathComponent:@"downloads/share/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath;
    NSError *error = nil;

    if (![fileManager fileExistsAtPath:folder]){
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
    }

    if (!error) {
        filePath = [folder stringByAppendingPathComponent:@"index_share.plist"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        // Removes file if already there
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtURL:fileURL error:nil];
        }

        BOOL success = [representation writeToFile:filePath atomically:YES];

        if (!success) {
            [RigelErrorHandler handleError:[NSError errorWithDomain:RigelErrorDomain code:1002 userInfo:nil] withCustomDescription:@"Saving share index array to plist failed."];
        }
    }

    if (error) {
        [RigelErrorHandler handleError:[NSError errorWithDomain:RigelErrorDomain code:1003 userInfo:error.userInfo]];
    }

    return filePath;
}

- (void)shareTracksRepresentationFromPath:(NSString *)path {
    [self.sessionManager sendResourceAtURL:[NSURL fileURLWithPath:path] progress:^(NSProgress *progress) {
    } withCompletion:^(NSError *error) {
        if (error) {
            [RigelErrorHandler handleError:error withCustomDescription:nil];
            self.success = NO;
        } else {
            NSLog(@"Sucessfully shared Index file with local tracks with remote peer");
            self.success = YES;
        }

        dispatch_semaphore_signal(self.semaphore);
    }];
}

- (void)failOperation {
    self.success = NO;
    [self cancel];
}

@end
