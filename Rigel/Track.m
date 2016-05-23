//
//  Track.m
//  Rigel
//
//  Created by Cesar Barscevicius on 5/16/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "Track.h"

@interface Track ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *filePath;

@end

@implementation Track

- (instancetype)init {
    self = [self initWithTrackTitle:nil];
    return self;
}

- (instancetype)initWithTrackTitle:(NSString *)title {
    if (self = [super init]) {
        _title = title;
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/downloads/%@.mp3", _title]];
        _filePath = path;
    }

    return self;
}

- (BOOL)isLocal {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Track title: %@ is local: %d/n Full path %@", self.title, self.isLocal, self.filePath];
}

@end
