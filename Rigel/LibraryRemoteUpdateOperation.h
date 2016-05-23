//
//  LibraryRemoteUpdateOperation.h
//  Rigel
//
//  Created by Cesar Barscevicius on 5/22/16.
//  Copyright © 2016 Cesar Barscevicius. All rights reserved.
//

#import "RigelOperation.h"

@interface LibraryRemoteUpdateOperation : RigelOperation

- (instancetype)initWithSharedIndexFileURL:(NSURL *)fileURL NS_DESIGNATED_INITIALIZER;

@end
