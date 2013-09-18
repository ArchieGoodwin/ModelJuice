//
//  DKAVoucherVC.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/16/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookingDetails.h"
#import "Client.h"
#import "ClientContactPerson.h"
#import "Booking.h"
@interface DKAVoucherVC : UIViewController
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) BookingDetails *details;
@property (strong, nonatomic) Client *client;
@property (strong, nonatomic) ClientContactPerson *clientPerson;
@property (strong, nonatomic) Booking *booking;
@property (strong, nonatomic) NSString *overtimeString;
@end
