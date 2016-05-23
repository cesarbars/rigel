//
//  RigelAppContext.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/5/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "RigelAppContext.h"

#import "AbstractMultipeerController.h"
#import "MultipeerAdvertiserController.h"
#import "MultipeerBrowserController.h"

NSString * const RigelBaseURLString = @"https://rigel-media.s3.amazonaws.com/";

@implementation RigelAppContext

+ (RigelAppState)currentState {
    RigelAppState state;
    if ([[[UIDevice currentDevice] name] containsString:@"michelle"]) {
        state = RigelAppStateBrowser;
    } else {
        state = RigelAppStateAdvertiser;
    }
    return state;
}

+ (AbstractMultipeerController *)currentMultipeerController {
    static AbstractMultipeerController *multipeerController;
    if (multipeerController == nil) {
        switch ([self currentState]) {
            case RigelAppStateBrowser:
                multipeerController = [[MultipeerBrowserController alloc] init];
                break;
            case RigelAppStateAdvertiser:
                multipeerController = [[MultipeerAdvertiserController alloc] init];
                break;

            default:
                break;
        }
    }

    return multipeerController;
}

@end
