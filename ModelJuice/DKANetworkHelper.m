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




-(void)loginMe:(NSString *)login pwd:(NSString *)pwd completeBlock:(RCCompleteBlockWithPersonResult)completeBlock
{
    NSString *urlString = [NSString stringWithFormat:@"http://modeljuice.blueforcedev.com/Api/Person/ValidateLogon?PersonEmail=%@&PersonPassword=%@",  login, pwd];
    
    NSLog(@"loginMe url %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"[loginMe responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSDictionary *answer = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"loginMe success");
        
        if(completeBlock)
        {
            
            Person *person = [Person createEntityInContext];
            person.firstName = [[[answer objectForKey:@"ReturnValue"] objectForKey:@"Person"] objectForKey:@"FirstName"];
            person.lastName = [[[answer objectForKey:@"ReturnValue"] objectForKey:@"Person"] objectForKey:@"LastName"];
            person.personId = [[[answer objectForKey:@"ReturnValue"] objectForKey:@"Person"] objectForKey:@"PersonID"];
            person.personLogin = login;
            person.personPwd = pwd;
            person.personType = [NSNumber numberWithInteger:0];
            [Person saveDefaultContext];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[[answer objectForKey:@"ReturnValue"] objectForKey:@"Person"] objectForKey:@"PersonID"] forKey:@"PersonID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            completeBlock(person, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loginMe error %@", error.description);
        if(completeBlock)
        {
            completeBlock(nil, error);

        }
            
    }];
    
    
    [operation start];
}


-(void)getBookingsForPerson:(Person *)person completeBlock:(RCCompleteBlockWithBoolResult)completeBlock
{
    NSString *urlString = [NSString stringWithFormat:@"http://modeljuice.blueforcedev.com/Api/Booking/GetBookings"];
    
    NSLog(@"getBookingsForPerson url %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
   

    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"[getBookingsForPerson responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSDictionary *answer = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"getBookingsForPerson success");
        
        if(completeBlock)
        {
            
            
            completeBlock(YES, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"getBookingsForPerson error %@", error.description);
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
