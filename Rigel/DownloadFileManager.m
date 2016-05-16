//
//  DownloadFileManager.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/16/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "DownloadFileManager.h"

@interface DownloadFileManager ()

@property (nonatomic, strong, readwrite) NSFileManager *sharedFileManager;

@end

@implementation DownloadFileManager

@synthesize sharedFileManager = _sharedFileManager;

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DownloadFileManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.sharedFileManager = [NSFileManager defaultManager];
    });
    return sharedInstance;
}

- (BOOL)fileExistsAtURL:(NSURL *)URL {
    return [self.sharedFileManager fileExistsAtPath:URL.absoluteString];
}

@end
