//
//  ResourceDownloadOperation.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/23/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "RigelOperation.h"

@class MultipeerSessionManager;
@class Track;
@class Library;

typedef NS_OPTIONS(NSUInteger, RigelDownloadSource) {
    RigelSourceLocal = 1 << 0,
    RigelSourceRemote = 1 << 1,
};

typedef NS_ENUM(NSUInteger, RigelDownloadStatus) {
    RigelDownloadStatusPreparing,
    RigelDownloadStatusDownloading,
    RigelDownloadStatusComplete,
    RigelDownloadStatusCancelled,
};

@protocol ResourceDownloadDelegate <NSObject>

- (void)didBeginDownloadOperationForTrack:(Track *)track;
- (void)didReceiveSourcesAvailability:(RigelDownloadSource)availability forTrack:(Track *)track;
- (void)didReceiveSource:(RigelDownloadSource)source downloadStatusUpdate:(RigelDownloadStatus)status forTrack:(Track *)track;
- (void)didReceiveSource:(RigelDownloadSource)source progressUpdate:(double)fractionCompleted forTrack:(Track *)track;

@end

@interface ResourceDownloadOperation : RigelOperation

- (instancetype)initWithSessionManager:(MultipeerSessionManager *)sessionManager track:(Track *)track library:(Library *)library NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id <ResourceDownloadDelegate> delegate;

@end
