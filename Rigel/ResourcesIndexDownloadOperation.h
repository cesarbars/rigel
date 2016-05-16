//
//  ResourcesIndexDownloadOperation.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/11/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MultipeerSessionManager;

@interface ResourcesIndexDownloadOperation : NSOperation

- (instancetype)initWithResourcesIndexURL:(NSURL *)resourcesURL sessionManager:(MultipeerSessionManager *)sessionManager completionHandler:(void (^)(NSDictionary *indexDictionary))completionHandler NS_DESIGNATED_INITIALIZER;

@end
