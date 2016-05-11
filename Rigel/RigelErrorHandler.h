//
//  RigelErrorHandler.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/11/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RigelErrorHandler : NSObject

+ (void)handleError:(NSError *)error;

+ (void)handleError:(NSError *)error withCustomDescription:(NSString *)description;

@end
