//
//  DKADetailsVC.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/2/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Booking.h"
#import "BookingDetails.h"
@interface DKADetailsVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Booking *booking;
@property (strong, nonatomic) BookingDetails *bookingDetail;
@property (strong, nonatomic) IBOutlet UITableView *table;


@end
