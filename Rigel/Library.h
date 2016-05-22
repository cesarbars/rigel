//
//  Library.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

@import Foundation;

@class Track;

@interface Library : NSObject

// when ready, Library begins requesting changes to be sent to the connected peers
@property (nonatomic, getter=isReady) BOOL ready;

- (void)addTrack:(Track *)track;
- (void)replaceTracks:(NSArray <Track *> *)tracks;

- (Track *)findTrackWithTitle:(NSString *)title;
- (BOOL)updateTrack:(Track *)newTrack;

- (NSArray <Track *> *)allTracks;

@end
