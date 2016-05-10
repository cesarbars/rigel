//
//  AbstractMultipeerController.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/2/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "AbstractMultipeerController.h"

NSString * const RigelServiceType = @"riguel-media";
NSString * const RigelSharedSecretKey = @"shared_secret";
NSString * const RigelSharedSecretValue = @"1234";

@interface AbstractMultipeerController ()

@property (nonatomic, strong)MCPeerID *peerID;

@end

@implementation AbstractMultipeerController

#pragma mark MultipeerConnectionProtocol

- (void)setup {

}

- (MCPeerID *)localPeerID {
    if (_peerID == nil) {
        _peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    }

    return _peerID;
}

@end
