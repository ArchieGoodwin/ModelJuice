//
//  DKANetworkHelper.h
//  ModelJuice
//
//  Created by Nero Wolfe on 8/29/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "Booking.h"
typedef void (^RCCompleteBlockWithBoolResult)  (BOOL result, NSError *error);
typedef void (^RCCompleteBlockWithPersonResult)  (Person *result, NSError *error);



@interface DKAHelper : NSObject
+(id)sharedInstance;

-(void)loginMe:(NSString *)login pwd:(NSString *)pwd completeBlock:(RCCompleteBlockWithPersonResult)completeBlock;
-(void)getBookingsForPerson:(Person *)person completeBlock:(RCCompleteBlockWithBoolResult)completeBlock;
-(CGFloat)getLabelSize:(NSString *)text font:(UIFont *)font width:(float)width;
-(void)getDetails:(Booking *)booking completeBlock:(RCCompleteBlockWithBoolResult)completeBlock;
-(void)getClient:(NSInteger)clientId completeBlock:(RCCompleteBlockWithBoolResult)completeBlock;
-(BOOL)isIphone5;
@end
