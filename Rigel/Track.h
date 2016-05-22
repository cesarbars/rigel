//
//  Track.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/16/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, getter=isLocal, readonly) BOOL localAvailable;
@property (nonatomic, getter=isRemote, readonly) BOOL remoteAvailable;

- (instancetype)initWithTrackTitle:(NSString *)title NS_DESIGNATED_INITIALIZER;

@end
