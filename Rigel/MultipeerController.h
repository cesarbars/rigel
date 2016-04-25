//
//  MultipeerController.h
//  Rigel
//
//  Created by Cesar Barscevicius on 4/25/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultipeerController : NSObject

@property (nonatomic, copy, nullable) void (^sessionDidBegin)();

@end
