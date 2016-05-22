//
//  LibraryShareOperaion.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "RigelOperation.h"

@class MultipeerSessionManager;

@interface LibraryShareOperation : RigelOperation

- (instancetype)initWithSessionManager:(MultipeerSessionManager *)sessionManager NS_DESIGNATED_INITIALIZER;

@end
