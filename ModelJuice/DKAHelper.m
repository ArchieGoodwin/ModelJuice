//
//  DKANetworkHelper.m
//  ModelJuice
//
//  Created by Nero Wolfe on 8/29/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAHelper.h"
#import "AFNetworking.h"
#import "DKADefines.h"
#import <UIKit/UIKit.h>
#import "DKAHTTPClient.h"
#import "Booking.h"
#import "BookingDetails.h"
#import "Client.h"
#import "ClientContactPerson.h"
@implementation DKAHelper


#pragma mark Helper methods

-(CGFloat)getLabelSize:(NSString *)text font:(UIFont *)font width:(float)width
{
    CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
    CGSize labelSize = [text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height;
}



#pragma mark Network methods

-(void)loginMe:(NSString *)login pwd:(NSString *)pwd completeBlock:(RCCompleteBlockWithPersonResult)completeBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@/Api/Person/ValidateLogon?PersonEmail=%@&PersonPassword=%@",  BASE_URL, login, pwd];
    
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
    NSString *urlString = [NSString stringWithFormat:@"%@/Api/Booking/GetBookings", BASE_URL];
    
    NSLog(@"getBookingsForPerson url %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];

    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"[getBookingsForPerson responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
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



-(void)getDetails:(Booking *)booking completeBlock:(RCCompleteBlockWithBoolResult)completeBlock
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    Person *person = [Person getSingleObjectByPredicate:predicate];
    [[DKAHTTPClient sharedManager] setUsername:person.personLogin andPassword:person.personPwd];
    [[DKAHTTPClient sharedManager] setParameterEncoding:AFJSONParameterEncoding];
    
    predicate = [NSPredicate predicateWithFormat:@"bookingID = %@", booking.bookingId];
    BookingDetails *bd = [BookingDetails getSingleObjectByPredicate:predicate];
    NSLog(@"BookingID %@", booking.bookingId);

    if(bd == nil)
    {
        [[DKAHTTPClient sharedManager] getPath:@"/Api/Booking/GetBookingDetails" parameters:@{@"Id": booking.bookingId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"success");
            //NSLog(@"[getDetails responseData]: %@",responseObject);
            
            NSDictionary *res = [[responseObject objectForKey:@"ReturnValue"] objectForKey:@"BookingDetails"];
            
            
            NSLog(@"BookingID %@", [res objectForKey:@"BookingID"]);
            BookingDetails *book = [BookingDetails createEntityInContext];
            book.bookingID = [res objectForKey:@"BookingID"];
            book.desc = [res objectForKey:@"Description"] == [NSNull null] ? @"" :[res objectForKey:@"Description"];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            //[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *startDate = [dateFormat dateFromString:[res objectForKey:@"StartDateTime"]];
            book.startDateTime = startDate;
            NSDate *endDate = [dateFormat dateFromString:[res objectForKey:@"EndDateTime"]];
            book.endDateTime = endDate;
            book.agencyID = [res objectForKey:@"AgencyID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"AgencyID"];
            book.agencyName = [res objectForKey:@"AgencyName"] == [NSNull null] ? @"" : [res objectForKey:@"AgencyName"];
            
            book.bookingTypeID = [res objectForKey:@"BookingTypeID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"BookingTypeID"];
            book.bookingTypeName = [res objectForKey:@"BookingTypeName"] == [NSNull null] ? @"" : [res objectForKey:@"BookingTypeName"];
            
            book.clientContactID = [res objectForKey:@"ClientContactID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ClientContactID"];
            book.clientContactName = [res objectForKey:@"ClientContactName"] == [NSNull null] ? @"" : [res objectForKey:@"ClientContactName"];
            
            book.clientID = [res objectForKey:@"ClientID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ClientID"];
            book.clientName = [res objectForKey:@"ClientName"] == [NSNull null] ? @"" : [res objectForKey:@"ClientName"];
            
            //book.hair = [res objectForKey:@"Hair"] == [NSNull null] ? @"" : [res objectForKey:@"Hair"];
            book.hourlyRate = [res objectForKey:@"HourlyRate"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"HourlyRate"];
            //book.makeup = [res objectForKey:@"Makeup"] == [NSNull null] ? @"" : [res objectForKey:@"Makeup"];
            book.modelID = [res objectForKey:@"ModelID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ModelID"];
            book.modelName = [res objectForKey:@"ModelName"] == [NSNull null] ? @"" : [res objectForKey:@"ModelName"];
            
            book.notes =  [res objectForKey:@"Notes"] == [NSNull null] ? @"" : [res objectForKey:@"Notes"];
            book.orHours = [res objectForKey:@"ORHours"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"ORHours"];
            book.otRate = [res objectForKey:@"OTRate"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"OTRate"];
            NSDate *paidDate = [NSDate date];
            if([res objectForKey:@"PaidDateTime"] != [NSNull null])
            {
                paidDate = [dateFormat dateFromString:[res objectForKey:@"PaidDateTime"]];
                
            }
            
            book.paidDateTime = paidDate;
            //book.stylist = [res objectForKey:@"Stylist"] == [NSNull null] ? @"" : [res objectForKey:@"Stylist"];
            //book.team = [res objectForKey:@"Team"] == [NSNull null] ? @"" : [res objectForKey:@"Team"];
            
            NSLog(@"clientID %@ booking id : %@", book.clientID, book.bookingID);
            
            completeBlock(YES, nil);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"getDetails error: %@", error.description);
            
            completeBlock(NO, error);

        }];
    }
   
    
}

-(void)getClient:(NSInteger)clientId completeBlock:(RCCompleteBlockWithBoolResult)completeBlock
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %i", clientId];
    Client *client = [Client getSingleObjectByPredicate:predicate];
    
    if(client == nil)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
        Person *person = [Person getSingleObjectByPredicate:predicate];
        [[DKAHTTPClient sharedManager] setUsername:person.personLogin andPassword:person.personPwd];
        [[DKAHTTPClient sharedManager] setParameterEncoding:AFJSONParameterEncoding];
        
        [[DKAHTTPClient sharedManager] getPath:@"/api/Client/GetClientDetails" parameters:@{@"Id": [NSNumber numberWithInteger:clientId]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"success");
            //NSLog(@"[getClient responseData]: %@",responseObject);
            
            NSDictionary *res = [[responseObject objectForKey:@"ReturnValue"] objectForKey:@"ClientDetails"];
            
            
            //NSLog(@"%@", res);
            Client *cli = [Client createEntityInContext];
            cli.clientID = [res objectForKey:@"ClientID"];
            cli.companyName = [res objectForKey:@"CompanyName"] == [NSNull null] ? @"" : [res objectForKey:@"CompanyName"];
            cli.phone = [res objectForKey:@"Phone"] == [NSNull null] ? @"" : [res objectForKey:@"Phone"];
            cli.addressLine1 = [res objectForKey:@"AddressLine1"] == [NSNull null] ? @"" : [res objectForKey:@"AddressLine1"];
            cli.addressLine2 = [res objectForKey:@"AddressLine2"] == [NSNull null] ? @"" : [res objectForKey:@"AddressLine2"];
            cli.city = [res objectForKey:@"City"] == [NSNull null] || [res objectForKey:@"City"] == nil ? @"11" : [res objectForKey:@"City"];
            cli.stateID = [res objectForKey:@"StateID"] == [NSNull null] ? [NSNumber numberWithInteger:0] : [res objectForKey:@"StateID"];
            cli.stateName = [res objectForKey:@"StateName"] == [NSNull null] ? @"" : [res objectForKey:@"StateName"];
            
            cli.zipcode = [res objectForKey:@"Zipcode"] == [NSNull null] ? @"" : [res objectForKey:@"Zipcode"];
            NSLog(@"%@", cli.city);
            for(NSDictionary *det in [res objectForKey:@"ClientContacts"])
            {
                ClientContactPerson *cliPerson = [ClientContactPerson createEntityInContext];
                cliPerson.personID = [[det objectForKey:@"ClientContactPerson"] objectForKey:@"PersonID"];
                cliPerson.personFullName =  [[det objectForKey:@"ClientContactPerson"] objectForKey:@"PersonFullName"] == [NSNull null] ? @"" :  [[det objectForKey:@"ClientContactPerson"] objectForKey:@"PersonFullName"];
                cliPerson.workPhone =  [[det objectForKey:@"ClientContactPerson"] objectForKey:@"WorkPhone"] == [NSNull null] ? @"" :  [[det objectForKey:@"ClientContactPerson"] objectForKey:@"WorkPhone"];
                cliPerson.clientID = cli.clientID;
                
            }
            
            completeBlock(YES, nil);

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"getClient error: %@", error.description);
            
            completeBlock(NO, error);


        }];
        
    }
    
    
}






-(BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                //NSLog(@"iPhone 4 Resolution");
                return NO;
            }
            if(result.height == 1136) {
                //NSLog(@"iPhone 5 Resolution");
                //[[UIScreen mainScreen] bounds].size =result;
                return YES;
            }
        }
        else{
            // NSLog(@"Standard Resolution");
            return NO;
        }
    }
    return NO;
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
    static DKAHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[DKAHelper alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    
    abort();
}

@end
