//
//  DownloadFileManager.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/16/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadFileManager : NSObject

@property (nonatomic, strong, readonly) NSFileManager *sharedFileManager;

+ (instancetype)sharedInstance;

- (BOOL)fileExistsAtURL:(NSURL *)URL;

@end
