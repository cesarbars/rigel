//
//  AbstractMultipeerController.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/2/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

@import Foundation;
@import UIKit;

#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "MultipeerSessionManager.h"

extern NSString * const RigelServiceType;
extern NSString * const RigelSharedSecretKey;
extern NSString * const RigelSharedSecretValue;

@protocol MultipeerConnectionProtocol <NSObject>

- (void)setup;
- (void)disableDiscoverability;

@end

@protocol MultipeerConnectionDelegate <NSObject>

@optional
- (void)lostConnectedPeer:(MCPeerID *)peerID;

@end

@interface AbstractMultipeerController : NSObject <MultipeerConnectionProtocol>

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) MultipeerSessionManager *sessionManager;

- (MCPeerID*)localPeerID;

- (void)setup;

@end
