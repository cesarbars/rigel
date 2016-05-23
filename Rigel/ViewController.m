//
//  ViewController.m
//  Rigel
//
//  Created by Cesar Barscevicius on 4/24/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "ViewController.h"

#import "AbstractMultipeerController.h"
#import "LibraryBuildOperation.h"
#import "LibraryShareOperation.h"
#import "LibraryRemoteUpdateOperation.h"
#import "Library.h"
#import "MultipeerAdvertiserController.h"
#import "MultipeerBrowserController.h"
#import "MultipeerSessionManager.h"
#import "Track.h"
#import "ResourcesIndexDownloadOperation.h"
#import "RigelAppContext.h"
#import "RigelAppContext.h"

NSString * const RigelIndexShareFilename = @"index_share.plist";

@interface ViewController () <MultipeerConnectionDelegate, MultipeerSessionManagerDelegate>

@property (nonatomic, strong) AbstractMultipeerController *multipeerController;

@property (nonatomic, strong) LibraryShareOperation *libraryShareOperation;
@property (nonatomic, strong) Library *library;

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
    // ResourcesIndexDownloadOperation
    ResourcesIndexDownloadOperation *indexOperation = [[ResourcesIndexDownloadOperation alloc] initWithResourcesIndexURL:[NSURL URLWithString:@"https://rigel-media.s3.amazonaws.com/index.plist"]];
    indexOperation.qualityOfService = NSQualityOfServiceUtility;

    // LibraryBuildOperation
    LibraryBuildOperation *libraryBuildOperation = [[LibraryBuildOperation alloc] init];
    libraryBuildOperation.qualityOfService = NSQualityOfServiceUtility;
    [libraryBuildOperation addDependency:indexOperation];
    __weak __typeof__(self) weakSelf = self;
    __weak __typeof__(LibraryBuildOperation *) weakLibraryBuildOperation = libraryBuildOperation;
    libraryBuildOperation.completionBlock = ^{
        if ([weakLibraryBuildOperation.data isKindOfClass:[Library class]]) {
            weakSelf.library = (Library *)weakLibraryBuildOperation.data;
        }
    };

    // LibraryShareOperation
    self.libraryShareOperation = [[LibraryShareOperation alloc] initWithSessionManager:self.multipeerController.sessionManager];
    self.libraryShareOperation.qualityOfService = NSQualityOfServiceUtility;
    [self.libraryShareOperation addDependency:libraryBuildOperation];

    [[NSOperationQueue mainQueue] addOperation:indexOperation];
    [[NSOperationQueue mainQueue] addOperation:libraryBuildOperation];
    [[NSOperationQueue mainQueue] addOperation:self.libraryShareOperation];
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
    if ([resourceName isEqualToString:RigelIndexShareFilename]) {
        NSLog(@"Received index share file.");

        LibraryRemoteUpdateOperation *updateOperation = [[LibraryRemoteUpdateOperation alloc] initWithSharedIndexFileURL:localURL];
        updateOperation.qualityOfService = NSQualityOfServiceUserInteractive;
        [updateOperation addDependency:self.libraryShareOperation];

        [[NSOperationQueue mainQueue] addOperation:updateOperation];
    }
}

@end
