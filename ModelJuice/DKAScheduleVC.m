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
#import "CKCalendarView.h"
#import "DKADefines.h"
#import "DKADetailsVC.h"
#import "Client.h"
#import "ClientContactPerson.h"
#define CELL_HEIGHT 44


@interface DKAScheduleVC () <CKCalendarDelegate>
{
    NSMutableArray *bookings;
    CGRect tableFrame;
    BOOL calendarShown;
    UIRefreshControl *refreshControl;

}

@property(nonatomic, weak) CKCalendarView *calendar;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;

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
    
    
    UIButton *btnLense = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnLense.frame = CGRectMake(0, 3, 16, 17);
    [btnLense setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithCustomView:btnLense];
    
    
    UIButton *btnPlus = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnPlus.frame = CGRectMake(0, 0, 16, 16);
    [btnPlus setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithCustomView:btnPlus];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                              target:nil
                                                                              action:nil];
    flexItem.width = 35;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:plusButton, flexItem, searchButton, nil];
    
    
    
    refreshControl = [[UIRefreshControl alloc]   init];
    refreshControl.tintColor = MAIN_ORANGE;
    
    [refreshControl addTarget:self action:@selector(refreshSchedule) forControlEvents:UIControlEventValueChanged];
    
    [self.table addSubview:refreshControl];

    
    
    tableFrame = self.table.frame;
    
    calendarShown = NO;
    
    [self createCalendar];
    
    [self showBookings];
    
    if(bookings.count == 0)
    {
        [self refreshSchedule];

    }
    
    self.table.separatorColor = MAIN_BACK_COLOR;
    
    [self preferredStatusBarStyle];
	// Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(calendarShown)
    {
        calendarShown = NO;
        
        
        self.table.frame = tableFrame;
        
        self.calendar.frame = CGRectMake(0, -257, 320, 217);
            
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}

-(void)createCalendar
{
    CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
    self.calendar = calendar;
    calendar.delegate = self;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd/MM/yyyy"];
    self.minimumDate = [self.dateFormatter dateFromString:@"20/09/2012"];
    
    /*self.disabledDates = @[
     [self.dateFormatter dateFromString:@"05/01/2013"],
     [self.dateFormatter dateFromString:@"06/01/2013"],
     [self.dateFormatter dateFromString:@"07/01/2013"]
     ];*/
    
    calendar.onlyShowCurrentMonth = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = NO;
    
    calendar.frame = CGRectMake(0, -257, 320, 217);
    
    [self.view addSubview:calendar];
}

-(IBAction)showCalendar:(id)sender
{
    if(calendarShown)
    {
        
        calendarShown = NO;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            self.table.frame = tableFrame;

            self.calendar.frame = CGRectMake(0, -257, 320, 217);

        }];

    }
    else
    {
        
        
        
        [UIView animateWithDuration:0.4 animations:^{
            
            
            
            calendarShown = YES;
            
            self.calendar.frame = CGRectMake(0, 0, 320, 217);

            
            CGRect frame = self.table.frame;
            frame.origin.y = 235;
            frame.size.height = frame.size.height - 235;
            self.table.frame = frame;
        }];
    }
    
    
    
    
    
   
   
}


-(void)showBookings
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    bookings = [Booking getFilteredRecordsWithSortedPredicate:predicate key:@"startDate" ascending:NO];
    
    [self.table reloadData];
    
   
    
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
        for(BookingDetails *book in [BookingDetails getAllRecords])
        {
            [BookingDetails deleteInContext:book];
        }
        for(Client *book in [Client getAllRecords])
        {
            [Client deleteInContext:book];
        }
        for(ClientContactPerson *book in [ClientContactPerson getAllRecords])
        {
            [ClientContactPerson deleteInContext:book];
        }
        
        
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
                [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSDate *startDate = [dateFormat dateFromString:[[booking objectForKey:@"Booking"] objectForKey:@"StartDateTime"]];
                
                book.startDate = startDate;
                NSDate *endDate = [dateFormat dateFromString:[[booking objectForKey:@"Booking"] objectForKey:@"EndDateTime"]];
                book.endDate = endDate;
                book.personId = person.personId;
                book.bookingType = [[booking objectForKey:@"Booking"] objectForKey:@"BookingTypeID"] == [NSNull null] ? [NSNumber numberWithInt:0] :[[booking objectForKey:@"Booking"] objectForKey:@"BookingTypeID"];
                book.bookingTypeName = [[booking objectForKey:@"Booking"] objectForKey:@"BookingTypeName"] == [NSNull null] ? @"" :[[booking objectForKey:@"Booking"] objectForKey:@"BookingTypeName"];
                book.clientID = [[booking objectForKey:@"Booking"] objectForKey:@"ClientID"] == [NSNull null] ? [NSNumber numberWithInt:0] :[[booking objectForKey:@"Booking"] objectForKey:@"ClientID"];
                book.clientName = [[booking objectForKey:@"Booking"] objectForKey:@"ClientName"] == [NSNull null] ? @"" :[[booking objectForKey:@"Booking"] objectForKey:@"ClientName"];




            }
        }
        [Booking saveDefaultContext];
        
        [self showBookings];
        
         [refreshControl endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
         [refreshControl endRefreshing];
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
    
    ((UILabel *)[cell.contentView viewWithTag:101]).text = book.clientName;
    ((UILabel *)[cell.contentView viewWithTag:102]).text = book.bookingTypeName;

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormat setDateFormat:@"EEEE, MMM dd"];

    NSString *str = [dateFormat stringFromDate:book.startDate];
    ((UILabel *)[cell.contentView viewWithTag:103]).text = str;
    
    [dateFormat setDateFormat:@"hh:mma"];
    NSString *strHS = [dateFormat stringFromDate:book.startDate];
    NSString *strHE = [dateFormat stringFromDate:book.endDate];
    
    ((UILabel *)[cell.contentView viewWithTag:104]).text = [NSString stringWithFormat:@"%@ - %@", strHS, strHE];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Booking *book = [bookings objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:@"PushDetail" sender:book];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushDetail"])
    {
        DKADetailsVC *detail = (DKADetailsVC *)segue.destinationViewController;
        
        detail.booking = sender;
    }
}

#pragma mark - CKCalendarDelegate

- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {

    
    for(Booking *book in bookings)
    {
        if([self.calendar date:date isSameDayAsDate:book.startDate])
        {
            dateItem.backgroundColor = MAIN_BACK_COLOR;
            dateItem.textColor = [UIColor darkTextColor];
        }
    }
    
}

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    //self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    
    int i = 0;
    for(Booking *book in bookings)
    {
        if([self.calendar date:date isSameDayAsDate:book.startDate])
        {
            
            CGPoint offset = CGPointMake(0, CELL_HEIGHT * i);
            [self.table setContentOffset:offset animated:YES];
            
            return;
        }
        i++;
    }
    
    
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    if ([date laterDate:self.minimumDate] == date) {
        self.calendar.backgroundColor = MAIN_BACK_COLOR;
        return YES;
    } else {
        self.calendar.backgroundColor = MAIN_BACK_COLOR;
        return NO;
    }
}

- (void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame {
    NSLog(@"calendar layout: %@", NSStringFromCGRect(frame));
}


@end
