//
//  DKAHTTPClient.h
//  ModelJuice
//
//  Created by Nero Wolfe on 8/30/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFHTTPClient.h"

@interface DKAHTTPClient : AFHTTPClient


- (void)setUsername:(NSString *)username andPassword:(NSString *)password;

+ (DKAHTTPClient *)sharedManager;

@end
