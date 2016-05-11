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
#import "PopulateResourcesIndexOperation.h"
#import "RigelAppContext.h"
#import "RigelAppContext.h"

@interface ViewController () <MultipeerConnectionDelegate, MultipeerSessionManagerDelegate>

@property (nonatomic, strong) AbstractMultipeerController *multipeerController;

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
            self.navigationItem.title = description;
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

- (void)beginIndexOperation {
    PopulateResourcesIndexOperation *indexOperation = [[PopulateResourcesIndexOperation alloc] initWithResourcesIndexURL:[NSURL URLWithString:@"https://rigel-media.s3.amazonaws.com/index.plist"] sessionManager:self.multipeerController.sessionManager];
    indexOperation.qualityOfService = NSQualityOfServiceUtility;

    [[NSOperationQueue mainQueue] addOperation:indexOperation];
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

- (void)peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    UIColor *color;

    switch (state) {
        case MCSessionStateNotConnected: {
            color = [UIColor colorWithRed:1.0 green:.451 blue:.424 alpha:1.0];
            // Tries to reconnect
            [self setup];
        }
            break;
        case MCSessionStateConnected: {
            color = [UIColor colorWithRed:.345 green:.816 blue:.404 alpha:1.0];
            // Stops browsing/advertising peers
            [self.multipeerController disableDiscoverability];
            [self beginIndexOperation];
        }
        break;
        case MCSessionStateConnecting: {
            color = [UIColor colorWithRed:1.0 green:.835 blue:.424 alpha:1.0];
        }
            break;

        default: {
            color = [UIColor colorWithRed:1.0 green:.451 blue:.424 alpha:1.0];
        }
            break;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.navigationBar.barTintColor = color;
    });
}

- (void)didReceiveResource:(NSString *)resourceName atURL:(NSURL *)localURL {
    NSLog(@"Got resources");
}

@end
