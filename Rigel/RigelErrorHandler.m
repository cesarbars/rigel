//
//  RigelErrorHandler.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/11/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "RigelErrorHandler.h"

@implementation RigelErrorHandler

+ (void)handleError:(NSError *)error {
    [self handleError:error withCustomDescription:nil];
}

+ (void)handleError:(NSError *)error withCustomDescription:(NSString *)customDescription {
    NSLog(@"An error occurred: %@ %@", error.description, customDescription);
}

@end
