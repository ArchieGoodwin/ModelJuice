//
//  DKAScheduleVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 8/30/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAScheduleVC.h"
#import "Person.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "DKANetworkHelper.h"
#import "DKAHTTPClient.h"
#import "Booking.h"
@interface DKAScheduleVC ()
{
    NSMutableArray *bookings;
}
@end

@implementation DKAScheduleVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshSchedule];
    
    [self preferredStatusBarStyle];
	// Do any additional setup after loading the view.
}


-(void)refreshSchedule
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    Person *person = [Person getSingleObjectByPredicate:predicate];
    [[DKAHTTPClient sharedManager] setUsername:person.personLogin andPassword:person.personPwd];
    
    [[DKAHTTPClient sharedManager] getPath:@"/Api/Booking/GetBookings" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        NSLog(@"[getBookingsForPerson responseData]: %@",responseObject);
        for(Booking *book in [Booking getAllRecords])
        {
            [Booking deleteInContext:book];
        }
        [Booking saveDefaultContext];
        
        for(NSDictionary *bookingGroup in [[responseObject objectForKey:@"ReturnValue"] objectForKey:@"BookingGroups"])
        {
            for(NSDictionary *booking in [bookingGroup objectForKey:@"Bookings"])
            {
                NSLog(@"%@", booking);
                Booking *book = [Booking createEntityInContext];
                book.bookingId = [[booking objectForKey:@"Booking"] objectForKey:@"BookingID"];
                book.desc = [[booking objectForKey:@"Booking"] objectForKey:@"Description"];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                [dateFormat setDateFormat:@"yyyy-MM-ddTHH:mm:ss"];
                NSDate *startDate = [dateFormat dateFromString:[[booking objectForKey:@"Booking"] objectForKey:@"StartDateTime"]];
                
                book.startDate = startDate;
                NSDate *endDate = [dateFormat dateFromString:[[booking objectForKey:@"Booking"] objectForKey:@"EndDateTime"]];
                book.endDate = endDate;
                book.personId = person.personId;

            }
        }
        [Booking saveDefaultContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
        bookings = [Booking getFilteredRecordsWithSortedPredicate:predicate key:@"startDate" ascending:NO];
        
        [self.table reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }];
    
    
   
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return bookings.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BookingCell"];
    
    Booking *book = [bookings objectAtIndex:indexPath.row];
    
    ((UILabel *)[cell.contentView viewWithTag:101]).text = book.desc;
    
    // Configure the cell...
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
