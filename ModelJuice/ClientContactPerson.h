//
//  ClientContactPerson.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/3/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ClientContactPerson : NSManagedObject

@property (nonatomic, retain) NSNumber * clientID;
@property (nonatomic, retain) NSNumber * personID;
@property (nonatomic, retain) NSString * personFullName;
@property (nonatomic, retain) NSString * workPhone;

@end
