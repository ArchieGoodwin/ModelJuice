//
//  Client.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/4/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Client : NSManagedObject

@property (nonatomic, retain) NSString * addressLine1;
@property (nonatomic, retain) NSString * addressLine2;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * clientID;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * stateID;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) NSString * stateName;

@end
