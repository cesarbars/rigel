//
//  LibraryShareOperaion.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "LibraryShareOperation.h"
#import "Library.h"

@implementation LibraryShareOperation

- (void)main {
    RigelOperation *lastDependency = (RigelOperation *)self.dependencies.lastObject;
    if (!lastDependency.success) {
        [self failOperation];
        return;
    }

    Library *library = nil;
    if ([lastDependency.data isKindOfClass:[Library class]]) {
        library = (Library *)lastDependency.data;
    } else {
        [self failOperation];
        return;
    }

    if (library) {
        NSLog(@"Share Library %@", library);
    }

}

- (void)failOperation {
    self.success = NO;
    [self cancel];
}

@end
