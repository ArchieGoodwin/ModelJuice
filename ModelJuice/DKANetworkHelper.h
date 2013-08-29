//
//  DKANetworkHelper.h
//  ModelJuice
//
//  Created by Nero Wolfe on 8/29/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^RCCompleteBlockWithBoolResult)  (BOOL result, NSError *error);



@interface DKANetworkHelper : NSObject
+(id)sharedInstance;

-(void)loginMe:(NSString *)login pwd:(NSString *)pwd completeBlock:(RCCompleteBlockWithBoolResult)completeBlock;
@end
