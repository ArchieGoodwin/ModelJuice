//
//  DKASecondViewController.m
//  ModelJuice
//
//  Created by Nero Wolfe on 8/28/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKASecondViewController.h"
#import "DKAAppDelegate.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "Booking.h"
#import "BookingDetails.h"
#import "Person.h"
@interface DKASecondViewController ()

@end

@implementation DKASecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnSignOut:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"PersonID"];
    
    for(Booking *book in [Booking getAllRecords])
    {
        [Booking deleteInContext:book];
    }
    for(BookingDetails *book in [BookingDetails getAllRecords])
    {
        [BookingDetails deleteInContext:book];
    }
    for(Person *book in [Person getAllRecords])
    {
        [Person deleteInContext:book];
    }


    [Booking saveDefaultContext];
    
    
    DKAAppDelegate *appDelegate =  (DKAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate resetWindowToInitialView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
