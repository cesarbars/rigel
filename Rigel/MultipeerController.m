//
//  MultipeerController.m
//  Rigel
//
//  Created by Cesar Barscevicius on 4/25/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "MultipeerController.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

static NSString * const RigelServiceType = @"riguel-media";

@interface MultipeerController () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCSession *session;

@end

@implementation MultipeerController

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (MCPeerID *)localPeerID {
    return [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
}

#pragma mark - Instance Methods

- (void)setupAdvertiserConnection {

    MCNearbyServiceAdvertiser *advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:[self localPeerID] discoveryInfo:@{@"shared_secret" : @"1234"} serviceType:RigelServiceType];
    advertiser.delegate = self;
    [advertiser startAdvertisingPeer];
    self.advertiser = advertiser;
}

- (void)setupBrowserConnection {
    MCNearbyServiceBrowser *browser = [[MCNearbyServiceBrowser alloc] initWithPeer:[self localPeerID] serviceType:RigelServiceType];
    browser.delegate = self;
    [browser startBrowsingForPeers];
    self.browser = browser;
}

#pragma mark - Delegates & Data sources

#pragma mark - Advertiser Delegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    NSLog(@"Invitation");
}

#pragma mark - Browser Delegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    // Peer found
    if ([[info objectForKey:@"shared_secret"]isEqualToString:@"1234"]) {
        MCSession *session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.session = session;
        if (self.sessionDidBegin) self.sessionDidBegin();
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"Lost peer");
}

#pragma mark - Class lifecycle

- (instancetype)init {
    if (self = [super init]) {
#if (TARGET_OS_SIMULATOR)
        [self setupAdvertiserConnection];
#else
        [self setupBrowserConnection];
#endif
    }
    return self;
}

@end
