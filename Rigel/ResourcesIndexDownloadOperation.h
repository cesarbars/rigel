//
//  ResourcesIndexDownloadOperation.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/11/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

@import Foundation;

#import "RigelOperation.h"

@interface ResourcesIndexDownloadOperation : RigelOperation

- (instancetype)initWithResourcesIndexURL:(NSURL *)resourcesURL;

@end
