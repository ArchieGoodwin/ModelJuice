//
//  Booking.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/3/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Booking : NSManagedObject

@property (nonatomic, retain) NSNumber * bookingId;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * personId;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * bookingTypeName;
@property (nonatomic, retain) NSNumber * bookingType;
@property (nonatomic, retain) NSNumber * clientID;
@property (nonatomic, retain) NSString * clientName;

@end
