//
//  MultipeerAdvertiserController.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/5/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "MultipeerAdvertiserController.h"

@interface MultipeerAdvertiserController () <MultipeerConnectionProtocol, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCSession *localSession;

@end

@implementation MultipeerAdvertiserController

#pragma mark MultipeerConnectionProtocol

- (void)setup {
    MCNearbyServiceAdvertiser *advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:[self localPeerID] discoveryInfo:@{RigelSharedSecretKey : RigelSharedSecretValue} serviceType:RigelServiceType];
    advertiser.delegate = self;
    [advertiser startAdvertisingPeer];
    self.advertiser = advertiser;

    MCSession *session = [[MCSession alloc] initWithPeer:[self localPeerID]];
    self.localSession = session;

    self.sessionManager = [[MultipeerSessionManager alloc] initWithSession:self.localSession];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {

//    NSDictionary *info = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:context];
//    if ([[info objectForKey:RigelSharedSecretKey]isEqualToString:RigelSharedSecretValue]) {

        invitationHandler(YES, self.localSession);
//    }
}

@end
