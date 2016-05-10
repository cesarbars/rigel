//
//  MultipeerSessionManager.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/2/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "MultipeerSessionManager.h"

#import <MultipeerConnectivity/MCSession.h>

@interface MultipeerSessionManager () <MCSessionDelegate>

@property (nonatomic, readwrite) MCSessionState state;
@property (nonatomic, strong) void (^progressBlock)(NSProgress *progress);

@end

@implementation MultipeerSessionManager

#pragma mark Init

- (instancetype)init {
    self = [self initWithSession:nil];
    return self;
}

- (instancetype)initWithSession:(MCSession *)session {
    if (self = [super init]) {
        _session = session;
        _session.delegate = self;
    }

    return self;
}

#pragma mark Getters and Setters

- (void)setSession:(MCSession *)session {
    _session = session;
    _session.delegate = self;
}

- (void)sendResourceAtURL:(NSURL *)filePath progress:(void (^)(NSProgress *progress))progressBlock withCompletion:(void (^)(NSError *))completionBlock {
    NSProgress *progress = [self.session sendResourceAtURL:filePath withName:filePath.lastPathComponent toPeer:self.session.connectedPeers.firstObject withCompletionHandler:completionBlock];

    self.progressBlock = progressBlock;
    if (self.progressBlock) {
        [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.progressBlock && [object isKindOfClass:[NSProgress class]]) {
        self.progressBlock((NSProgress *)object);
    }
}

#pragma mark MCSessionDelegate 

// Remote peer changed state.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSLog(@"Peer : %@ did change to :%ld", peerID, state);
    if ([self.delegate respondsToSelector:@selector(didChangeState:)]) {
        self.state = state;
        [self.delegate didChangeState:state];
    }
}

// Received data from remote peer.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {

}

// Received a byte stream from remote peer.
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {

}

// Start receiving a resource from remote peer.
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSLog(@"Did begin receiving %@", resourceName);
}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(nullable NSError *)error {
    NSLog(@"Did finish receiving %@", resourceName);
}

// Made first contact with peer and have identity information about the
// remote peer (certificate may be nil).
- (void) session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler {
    certificateHandler(YES);
}

@end