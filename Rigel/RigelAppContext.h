//
//  RigelAppContext.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/5/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AbstractMultipeerController;

typedef NS_ENUM(NSUInteger, RigelAppState) {
    RigelAppStateBrowser,
    RigelAppStateAdvertiser,
};

@interface RigelAppContext : NSObject

+ (RigelAppState)currentState;
+ (AbstractMultipeerController *)currentMultipeerController;

@end
