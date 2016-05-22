//
//  Library.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "Library.h"
#import "Track.h"

@interface Library ()

@property (nonatomic, strong) NSMutableArray <Track *> *tracks;

@end

@implementation Library

- (NSMutableArray<Track *> *)tracks {
    if (_tracks == nil) {
        _tracks = [[NSMutableArray alloc] init];
    }
    
    return _tracks;
}

- (void)addTrack:(Track *)track {
    [self.tracks addObject:track];
}

- (void)replaceTracks:(NSArray <Track *> *)tracks {
    [self.tracks removeAllObjects];
    [self.tracks addObjectsFromArray:tracks];
}

- (Track *)findTrackWithTitle:(NSString *)title {
    for (Track *track in self.tracks) {
        if ([track.title isEqualToString:title]) {
            return track;
        }
    }
    return nil;
}

- (BOOL)updateTrack:(Track *)newTrack {
    for (Track *oldtrack in self.tracks) {
        if ([oldtrack.title isEqualToString:newTrack.title]) {
            [self.tracks replaceObjectAtIndex:[self.tracks indexOfObject:oldtrack] withObject:newTrack];
            return YES;
        }
    }

    return NO;
}

- (NSArray <Track *> *)allTracks {
    return [self.tracks copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Library %@", self.allTracks];
}

@end
