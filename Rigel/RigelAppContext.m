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

@implementation RigelAppContext

+ (RigelAppState)currentState {
    RigelAppState state;
#if (TARGET_OS_SIMULATOR)
    state = RigelAppStateAdvertiser;
#else
    state = RigelAppStateBrowser;
#endif

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
