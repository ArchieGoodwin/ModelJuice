//
//  Person.h
//  ModelJuice
//
//  Created by Nero Wolfe on 8/30/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * personId;
@property (nonatomic, retain) NSString * personLogin;
@property (nonatomic, retain) NSString * personPwd;
@property (nonatomic, retain) NSNumber * personType;

@end
