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
@interface DKAScheduleVC () <CKCalendarDelegate>
{
    NSMutableArray *bookings;
    CGRect tableFrame;
    BOOL calendarShown;
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
    
    tableFrame = self.table.frame;
    
    calendarShown = NO;
    
    [self showBookings];
    
    [self createCalendar];
    
    [self refreshSchedule];
    
    //[self showCalendar];
    
    [self preferredStatusBarStyle];
	// Do any additional setup after loading the view.
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

-(void)hideCalendar
{
       
   
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
                [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSDate *startDate = [dateFormat dateFromString:[[booking objectForKey:@"Booking"] objectForKey:@"StartDateTime"]];
                
                book.startDate = startDate;
                NSDate *endDate = [dateFormat dateFromString:[[booking objectForKey:@"Booking"] objectForKey:@"EndDateTime"]];
                book.endDate = endDate;
                book.personId = person.personId;

            }
        }
        [Booking saveDefaultContext];
        
        [self showBookings];
        
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

#pragma mark - CKCalendarDelegate

- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
    /*if ([self dateIsDisabled:date]) {
        dateItem.backgroundColor = [UIColor redColor];
        dateItem.textColor = [UIColor whiteColor];
    }*/
    
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
            [self.table reloadData];
            [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
