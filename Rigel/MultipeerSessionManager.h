//
//  MultipeerSessionManager.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/2/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

@import Foundation;

#import <MultipeerConnectivity/MCSession.h>

@protocol MultipeerSessionManagerDelegate <NSObject>

@optional
- (void)didChangeState:(MCSessionState)state;
- (void)didReceiveResource:(NSString *)resourceName atURL:(NSURL *)localURL;

@end

@interface MultipeerSessionManager : NSObject

@property (nonatomic, readonly) MCSessionState state;
@property (nonatomic, strong) MCSession *session;

@property (nonatomic, weak) id <MultipeerSessionManagerDelegate> delegate;

- (instancetype)initWithSession:(MCSession *)session NS_DESIGNATED_INITIALIZER;

- (void)sendResourceAtURL:(NSURL *)filePath progress:(void (^)(NSProgress *progress))progressBlock withCompletion:(void (^)(NSError *error))completionBlock;

@end
