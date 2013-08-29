//
//  DKANetworkHelper.m
//  ModelJuice
//
//  Created by Nero Wolfe on 8/29/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKANetworkHelper.h"
#import "AFNetworking.h"
@implementation DKANetworkHelper




-(void)loginMe:(NSString *)login pwd:(NSString *)pwd completeBlock:(RCCompleteBlockWithBoolResult)completeBlock
{
    NSString *urlString = [NSString stringWithFormat:@"http://modeljuice.blueforcedev.com/Api/Person/ValidateLogon?PersonEmail=%@&PersonPassword=%@",  login, pwd];
    
    NSLog(@"loginMe url %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"[loginMe responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

        NSLog(@"loginMe success");
        
        if(completeBlock)
        {
            completeBlock(YES, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loginMe error %@", error.description);
        if(completeBlock)
        {
            completeBlock(NO, error);

        }
            
    }];
    
    
    [operation start];
}




- (id)init {
    self = [super init];
    
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    
#else
    
    
#endif
    
    return self;
    
}



+(id)sharedInstance
{
    static dispatch_once_t pred;
    static DKANetworkHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[DKANetworkHelper alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    
    abort();
}

@end
