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

@interface ResourceDownloadOperation : RigelOperation

- (instancetype)initWithSessionManager:(MultipeerSessionManager *)sessionManager track:(Track *)track library:(Library *)library NS_DESIGNATED_INITIALIZER;

@end
