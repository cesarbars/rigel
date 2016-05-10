//
//  ViewController.m
//  Rigel
//
//  Created by Cesar Barscevicius on 4/24/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "ViewController.h"

#import "AbstractMultipeerController.h"
#import "MultipeerAdvertiserController.h"
#import "MultipeerBrowserController.h"
#import "MultipeerSessionManager.h"
#import "RigelAppContext.h"
#import "RigelAppContext.h"

@interface ViewController () <MultipeerConnectionDelegate, MultipeerSessionManagerDelegate>

@property (nonatomic, strong) AbstractMultipeerController *multipeerController;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController

- (AbstractMultipeerController *)multipeerController {
    if (_multipeerController == nil) {
        _multipeerController = [RigelAppContext currentMultipeerController];
        NSString *description;
        if ([_multipeerController isKindOfClass:[MultipeerBrowserController class]]) {
            description = [NSString stringWithFormat:@"%@ is Browsing", [UIDevice currentDevice].name];
        } else {
            description = [NSString stringWithFormat:@"%@ is Advertising", [UIDevice currentDevice].name];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = description;
        });
    }
    return _multipeerController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)setup {
    [self.multipeerController setup];
    self.multipeerController.delegate = self;
    self.multipeerController.sessionManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendFile {
    NSURL *resourceURL = [[NSBundle mainBundle] URLForResource:@"daddy" withExtension:@"mp3"];

    [self.multipeerController.sessionManager sendResourceAtURL:resourceURL progress:^(NSProgress *progress) {
        NSLog(@"Current progress: %lld", progress.totalUnitCount);
    } withCompletion:^(NSError *error) {
        NSLog(@"Finished with error %@", error);
    }];
}

#pragma mark Actions

- (IBAction)reload:(id)sender {
    [self setup];
}

#pragma mark MultipeerBrowserDelegate

- (void)lostConnectedPeer:(MCPeerID *)peerID {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Dispositivo desconectado" message:[NSString stringWithFormat:@"O dispositivo %@ foi desconectado", peerID.displayName] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil ];
}

#pragma mark MultipeerSessionManagerDelegate

- (void)didChangeState:(MCSessionState)state {
//    NSLog(@"%@ did change to state: %ld", [self.multipeerController localPeerID], (long)state);
//    if ((state == MCSessionStateConnected) && ([RigelAppContext currentState] == RigelAppStateBrowser)) {
//        [self sendFile];
//    }
}

- (void)didReceiveResource:(NSString *)resourceName atURL:(NSURL *)localURL {
    NSLog(@"Got resources");
}

@end
