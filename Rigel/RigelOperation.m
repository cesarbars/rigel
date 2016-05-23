//
//  RigelOperation.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "RigelOperation.h"

@implementation RigelOperation

- (void)failOperation {
    self.success = NO;
    [self cancel];
}

@end
