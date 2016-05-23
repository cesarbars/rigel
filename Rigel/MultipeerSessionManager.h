//
//  MultipeerSessionManager.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/2/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

@import Foundation;

#import <MultipeerConnectivity/MCSession.h>

extern NSString * const RigelRequestMessageKeyTitle;
extern NSString * const RigelRequestMessageKeyAction;
extern NSString * const RigelRequestMessageValueDownload;

@protocol MultipeerSessionManagerDelegate <NSObject>

@optional
- (void)peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state;

- (void)didStartReceivingResourceWithName:(NSString *)resourceName withProgress:(NSProgress *)progress;
- (void)didReceiveResource:(NSString *)resourceName atURL:(NSURL *)localURL;
- (void)didReceiveData:(NSData *)data;

@end

@interface MultipeerSessionManager : NSObject

@property (nonatomic, readonly) MCSessionState state;
@property (nonatomic, strong) MCSession *session;

@property (nonatomic, weak) id <MultipeerSessionManagerDelegate> delegate;
@property (nonatomic, weak) id <MultipeerSessionManagerDelegate> downloadDelegate;

- (instancetype)initWithSession:(MCSession *)session NS_DESIGNATED_INITIALIZER;

- (void)sendResourceAtURL:(NSURL *)filePath progress:(void (^)(NSProgress *progress))progressBlock withCompletion:(void (^)(NSError *error))completionBlock;

- (BOOL)sendData:(NSData *)data;

@end
