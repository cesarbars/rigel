//
//  MultipeerBrowserController.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/5/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "MultipeerBrowserController.h"

@interface MultipeerBrowserController () <MultipeerConnectionProtocol, MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCSession *localSession;

@end

@implementation MultipeerBrowserController

#pragma mark MultipeerConnectionProtocol

- (void)setup {
    MCNearbyServiceBrowser *browser = [[MCNearbyServiceBrowser alloc] initWithPeer:[self localPeerID] serviceType:RigelServiceType];
    browser.delegate = self;
    [browser startBrowsingForPeers];
    self.browser = browser;

    MCSession *session = [[MCSession alloc] initWithPeer:[self localPeerID]];
    self.localSession = session;

    self.sessionManager = [[MultipeerSessionManager alloc] initWithSession:self.localSession];
}


#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    // Peer found
    if ([[info objectForKey:RigelSharedSecretKey]isEqualToString:RigelSharedSecretValue]) {
        NSDictionary *context = @{RigelSharedSecretKey : RigelSharedSecretValue};
        NSData *contextData = [NSKeyedArchiver archivedDataWithRootObject:context];

        [self.browser invitePeer:peerID toSession:self.localSession withContext:contextData timeout:30.0];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    if ([self.delegate respondsToSelector:@selector(lostConnectedPeer:)]) {
        [self.delegate lostConnectedPeer:peerID];
    }
}

@end
