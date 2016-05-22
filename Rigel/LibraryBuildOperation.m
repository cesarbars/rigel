//
//  LibraryBuildOperation.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "LibraryBuildOperation.h"
#import "Track.h"
#import "Library.h"

@implementation LibraryBuildOperation

- (void)main {
    RigelOperation *lastDependency = (RigelOperation *)self.dependencies.lastObject;
    if (!lastDependency.success) {
        self.success = NO;
        [self cancel];
        return;
    }

    NSArray *resourcesIndex = [self downloadedResourcesIndex];
    Library *library = nil;
    if (resourcesIndex) {
        library = [self createLocalLibraryFromIndex:resourcesIndex];
    }

    if (library) {
        NSLog(@"Library successfully created.");
        self.data = library;
        self.success = YES;
    }
}

- (NSArray *)downloadedResourcesIndex {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *folder = [documentsPath stringByAppendingPathComponent:@"downloads/index"];
    NSArray *directoryContent = [fileManager contentsOfDirectoryAtPath:folder error:NULL];
    NSString *filePath = [folder stringByAppendingPathComponent:directoryContent.firstObject];

    if ([fileManager fileExistsAtPath:filePath]) {
        // there's a file in the folder
        return [NSArray arrayWithContentsOfFile:filePath];
    }

    return nil;
}

- (Library *)createLocalLibraryFromIndex:(NSArray *)resourcesIndex {
    if (self.isCancelled) {
        return nil;
    }

    Library *library = [[Library alloc] init];

    for (NSDictionary *resource in resourcesIndex) {
        NSString *title = [resource objectForKey:@"title"];
        Track *track = [[Track alloc] initWithTrackTitle:title];

        [library addTrack:track];
    }

    return library;
}

@end
