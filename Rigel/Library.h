//
//  Library.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

@import Foundation;

@class Track;

@protocol LibraryDataDelegate <NSObject>

- (void)libraryTracksDidChange;

@end

@interface Library : NSObject

// when ready, Library begins requesting changes to be sent to the connected peers
@property (nonatomic, getter=isReady) BOOL ready;

@property (nonatomic, weak) id <LibraryDataDelegate> delegate;

- (void)addTrack:(Track *)track;
- (void)replaceTracks:(NSArray <Track *> *)tracks;

- (Track *)trackAtIndex:(NSUInteger)index;
- (Track *)findTrackWithTitle:(NSString *)title;
- (BOOL)updateTrack:(Track *)newTrack;

- (NSArray <Track *> *)allTracks;
- (NSUInteger)trackCount;

@end
