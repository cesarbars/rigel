//
//  LibraryRemoteUpdateOperation.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "LibraryRemoteUpdateOperation.h"
#import "Library.h"
#import "Track.h"
#import "RigelErrorHandler.h"

@interface LibraryRemoteUpdateOperation ()

@property (nonatomic, strong) NSURL *fileURL;

@end

@implementation LibraryRemoteUpdateOperation

- (instancetype)init {
    self = [self initWithSharedIndexFileURL:nil];

    return self;
}

- (instancetype)initWithSharedIndexFileURL:(NSURL *)fileURL {
    if (self = [super init]) {
        _fileURL = fileURL;
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


    NSArray *sharedIndexArray = [self sharedIndexArray];
    if (sharedIndexArray) {
        [self updateLibrary:library withAvailableRemoteTracksArray:sharedIndexArray];
        NSLog(@"Library update completed with remote available tracks.");
        self.success = YES;
    }

}

- (NSArray *)sharedIndexArray {
    return [NSArray arrayWithContentsOfURL:self.fileURL];
}

- (void)updateLibrary:(Library *)library withAvailableRemoteTracksArray:(NSArray *)sharedIndexArray {
    for (NSDictionary *trackRepresentation in sharedIndexArray) {
        Track *track = [[Track alloc] initWithTrackTitle:trackRepresentation[@"title"]];
        track.remoteAvailable = YES;
        BOOL success = [library updateTrack:track];
        if (!success) {
            [RigelErrorHandler handleError:[NSError errorWithDomain:RigelErrorDomain code:1006 userInfo:nil] withCustomDescription:[NSString stringWithFormat:@"Library track update failed for remote track %@", track]];
        }
    }
}

@end
