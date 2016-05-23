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
#import "ResourceDownloadOperation.h"
#import "RigelAppContext.h"
#import "RigelErrorHandler.h"


NSString * const RigelIndexShareFilename = @"index_share.plist";
NSString * const RigelReusableCellIdentifier = @"rigel-cell";

@interface ViewController () <MultipeerConnectionDelegate, MultipeerSessionManagerDelegate, LibraryDataDelegate, UITableViewDelegate, UITableViewDataSource, ResourceDownloadDelegate>

@property (nonatomic, strong) AbstractMultipeerController *multipeerController;
@property (nonatomic, strong) LibraryShareOperation *libraryShareOperation;
@property (nonatomic, strong) ResourceDownloadOperation *resourceDownloadOperation;
@property (nonatomic, strong) Library *library;
@property (nonatomic, strong) Track *activeTrack;
@property (nonatomic, strong) NSOperationQueue *rigelUtilityOperationQueue;
@property (nonatomic, strong) NSOperationQueue *rigelDownloadOperationQueue;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *downloadTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadLocalStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadRemoteStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadLocalTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadRemoteTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadLocalTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadRemoteTitleLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *downloadLocalProgressView;
@property (nonatomic, weak) IBOutlet UIProgressView *downloadRemoteProgressView;

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
    [self.multipeerController.sessionManager.session disconnect];

    [self.multipeerController setup];
    self.multipeerController.delegate = self;
    self.multipeerController.sessionManager.delegate = self;

    [self.rigelUtilityOperationQueue cancelAllOperations];
    self.rigelUtilityOperationQueue = [[NSOperationQueue alloc] init];
    self.rigelUtilityOperationQueue.name = @"Utility Operation Queue";
    self.rigelUtilityOperationQueue.qualityOfService = NSQualityOfServiceUtility;
    self.rigelUtilityOperationQueue.maxConcurrentOperationCount = 1;

    [self.rigelDownloadOperationQueue cancelAllOperations];
    self.rigelDownloadOperationQueue = [[NSOperationQueue alloc] init];
    self.rigelDownloadOperationQueue.name = @"Download Operation Queue";
    self.rigelDownloadOperationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    self.rigelDownloadOperationQueue.maxConcurrentOperationCount = 1;

    self.library = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self cleanAllLabels];
    });
}

- (void)cleanAllLabels {
    NSArray *labelsArray = @[self.downloadTitleLabel, self.downloadLocalStatusLabel, self.downloadRemoteStatusLabel, self.downloadLocalTimeLabel, self.downloadRemoteTimeLabel];
    for (UILabel *label in labelsArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            label.text = @"";
        });
    }

    self.downloadRemoteTitleLabel.alpha = 0.4f;
    self.downloadLocalTitleLabel.alpha = 0.4f;

    self.downloadLocalProgressView.progress = 0.0f;
    self.downloadRemoteProgressView.progress = 0.0f;
}

- (void)beginIndexOperation {
    // ResourcesIndexDownloadOperation
    ResourcesIndexDownloadOperation *indexOperation = [[ResourcesIndexDownloadOperation alloc] initWithResourcesIndexURL:[NSURL URLWithString:[RigelBaseURLString stringByAppendingString:@"index.plist"]]];
    indexOperation.qualityOfService = NSQualityOfServiceUtility;

    // LibraryBuildOperation
    LibraryBuildOperation *libraryBuildOperation = [[LibraryBuildOperation alloc] init];
    libraryBuildOperation.qualityOfService = NSQualityOfServiceUtility;
    [libraryBuildOperation addDependency:indexOperation];
    __weak __typeof__(self) weakSelf = self;
    __weak __typeof__(LibraryBuildOperation *) weakLibraryBuildOperation = libraryBuildOperation;
    libraryBuildOperation.completionBlock = ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        __strong __typeof__(LibraryBuildOperation *) strongLibraryBuildOperation = weakLibraryBuildOperation;
        if ([strongLibraryBuildOperation.data isKindOfClass:[Library class]]) {
            strongSelf.library = (Library *)strongLibraryBuildOperation.data;
            strongSelf.library.delegate = strongSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    };

    // LibraryShareOperation
    self.libraryShareOperation = [[LibraryShareOperation alloc] initWithSessionManager:self.multipeerController.sessionManager];
    self.libraryShareOperation.qualityOfService = NSQualityOfServiceUtility;
    [self.libraryShareOperation addDependency:libraryBuildOperation];

    [self.rigelUtilityOperationQueue addOperation:indexOperation];
    [self.rigelUtilityOperationQueue addOperation:libraryBuildOperation];
    [self.rigelUtilityOperationQueue addOperation:self.libraryShareOperation];
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
            self.library = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
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

        [self.rigelUtilityOperationQueue addOperation:updateOperation];
    }
}

- (void)didReceiveData:(NSData *)data {
    NSDictionary *message = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];

    if ([message[RigelRequestMessageKeyAction] isEqualToString:RigelRequestMessageValueDownload]) {
        // Download request
        Track *requestedTrack = [self.library findTrackWithTitle:message[RigelRequestMessageKeyTitle]];
        if (requestedTrack) {
            [self.multipeerController.sessionManager sendResourceAtURL:[NSURL fileURLWithPath:requestedTrack.filePath] progress:nil withCompletion:^(NSError *error) {
                if (!error) {
                    NSLog(@"File %@ sucessfully sent to local request.", requestedTrack.title);
                } else {
                    [RigelErrorHandler handleError:error];
                }
            }];
        }
    }

}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.library.trackCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RigelReusableCellIdentifier forIndexPath:indexPath];

    Track *track = [self.library trackAtIndex:indexPath.row];
    cell.textLabel.text = track.title;

    NSString *availabilityString = @"";
    if (track.isLocal) {
        availabilityString = [availabilityString stringByAppendingString:@"Downloaded "];
    }

    if (track.isRemoteAvailable) {
        if (availabilityString.length > 0) {
            availabilityString = [availabilityString stringByAppendingString:@"& "];
        }

        availabilityString = [availabilityString stringByAppendingString:@"MANET-Available "];
    }

    cell.detailTextLabel.text = availabilityString;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    Track *selectedTrack = [self.library trackAtIndex:indexPath.row];

    if (selectedTrack.isLocal) {
        // Local
        NSLog(@"Start playing %@", selectedTrack);
        return;
    }

    // Should start download operation
    self.resourceDownloadOperation = [[ResourceDownloadOperation alloc] initWithSessionManager:self.multipeerController.sessionManager track:selectedTrack library:self.library];
    self.resourceDownloadOperation.qualityOfService = NSQualityOfServiceUserInitiated;
    self.resourceDownloadOperation.delegate = self;

    [self.rigelDownloadOperationQueue addOperation:self.resourceDownloadOperation];
}

#pragma mark LibraryDataDelegate

- (void)libraryTracksDidChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark ResourceDownloadDelegate

- (void)didBeginDownloadOperationForTrack:(Track *)track {
    self.activeTrack = track;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self cleanAllLabels];
        self.downloadTitleLabel.text = [NSString stringWithFormat:@"%@.mp3", track.title];
    });
}

- (void)didReceiveSourcesAvailability:(RigelDownloadSource)availability forTrack:(Track *)track {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadLocalTitleLabel.alpha = 0.4f;
        self.downloadRemoteTitleLabel.alpha = 0.4f;

        if (availability & RigelSourceLocal) {
            self.downloadLocalTitleLabel.alpha = 1.0f;
        }

        if (availability & RigelSourceRemote) {
            self.downloadRemoteTitleLabel.alpha = 1.0f;
        }
    });
}

- (void)didReceiveSource:(RigelDownloadSource)source downloadStatusUpdate:(RigelDownloadStatus)status forTrack:(Track *)track {
    NSString *message = nil;
    UIColor *color = nil;
    switch (status) {
        case RigelDownloadStatusPreparing: {
            message = @"preparing";
            color = [UIColor colorWithRed:.36 green:.42 blue:.74 alpha:1.0];
        }
            break;
        case RigelDownloadStatusDownloading: {
            message = @"downloading";
            color = [UIColor colorWithRed:1.0 green:.835 blue:.424 alpha:1.0];
        }
            break;
        case RigelDownloadStatusComplete: {
            message = @"complete";
            color = [UIColor colorWithRed:.345 green:.816 blue:.404 alpha:1.0];
        }
            break;
        case RigelDownloadStatusCancelled: {
            message = @"cancelled";
            color = [UIColor colorWithRed:1.0 green:.451 blue:.424 alpha:1.0];

        }
            break;

        default: {
            message = @"";
            color = [UIColor whiteColor];
        }
            break;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (source == RigelSourceRemote) {
            self.downloadRemoteStatusLabel.text = message;
            self.downloadRemoteStatusLabel.textColor = color;
        } else {
            self.downloadLocalStatusLabel.text = message;
            self.downloadLocalStatusLabel.textColor = color;
        }
    });
}

- (void)didReceiveSource:(RigelDownloadSource)source progressUpdate:(double)fractionCompleted forTrack:(Track *)track {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (source == RigelSourceRemote) {
            [self.downloadRemoteProgressView setProgress:fractionCompleted animated:YES];
        } else {
            [self.downloadLocalProgressView setProgress:fractionCompleted animated:YES];
        }
    });
}

@end
