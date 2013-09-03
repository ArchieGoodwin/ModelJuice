//
//  BookingDetails.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/3/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BookingDetails : NSManagedObject

@property (nonatomic, retain) NSNumber * agencyID;
@property (nonatomic, retain) NSNumber * bookingID;
@property (nonatomic, retain) NSNumber * bookingTypeID;
@property (nonatomic, retain) NSNumber * clientContactID;
@property (nonatomic, retain) NSNumber * clientID;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * endDateTime;
@property (nonatomic, retain) NSString * hair;
@property (nonatomic, retain) NSNumber * hourlyRate;
@property (nonatomic, retain) NSString * makeup;
@property (nonatomic, retain) NSNumber * modelID;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * orHours;
@property (nonatomic, retain) NSNumber * otRate;
@property (nonatomic, retain) NSDate * paidDateTime;
@property (nonatomic, retain) NSDate * startDateTime;
@property (nonatomic, retain) NSString * stylist;
@property (nonatomic, retain) NSString * team;
@property (nonatomic, retain) NSString * agencyName;
@property (nonatomic, retain) NSString * bookingTypeName;
@property (nonatomic, retain) NSString * clientContactName;
@property (nonatomic, retain) NSString * clientName;
@property (nonatomic, retain) NSString * modelName;

@end
