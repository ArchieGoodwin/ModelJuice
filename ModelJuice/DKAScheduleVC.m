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
#import "DKAHelper.h"
#import "DKAHTTPClient.h"
#import "Booking.h"
#import "CKCalendarView.h"
#import "DKADefines.h"
#import "DKADetailsVC.h"
#import "Client.h"
#import "ClientContactPerson.h"
#import "UILabel+Boldify.h"
#import "NSDate-Utilities.h"
#import "Sequencer.h"
#import "MBProgressHUD.h"
#define CELL_HEIGHT 50


@interface DKAScheduleVC () <CKCalendarDelegate>
{
    NSMutableArray *bookings;
    CGRect tableFrame;
    BOOL calendarShown;
    UIRefreshControl *refreshControl;
    
    NSDate *selectedDate;

    
    NSMutableArray *sections;

}

@property(nonatomic, weak) CKCalendarView *calendar;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;

@end

@implementation DKAScheduleVC

#pragma mark ViewController methods

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
    
    
    /*UIButton *btnLense = [UIButton buttonWithType:UIButtonTypeRoundedRect];
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
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:plusButton, flexItem, searchButton, nil];*/
    
    self.navigationController.navigationBar.backgroundColor = MAIN_ORANGE;
    
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
    
    selectedDate = [NSDate date];
    
    self.table.separatorColor = SEPARATOR_COLOR;
    
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
    
    [self scrollBookingsToDate:selectedDate];
}

#pragma mark Logic


-(void)scrollBookingsToDate:(NSDate *)date
{
    //test date
    /*NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    date = [dateFormat dateFromString:@"08/09/2013"];
    */
    //
    
    
    
    int dateFound = -1;
    NSMutableArray *dates = [NSMutableArray new];
    for(int i = 0; i < bookings.count; i++)
    {
        Booking *book = bookings[i];
        if([date isEqualToDateIgnoringTime:book.startDate])
        {
            dateFound = i;
            break;
        }
        if([date isEarlierThanDate:book.startDate])
        {
            [dates addObject:book];
        }
    }

    if(dateFound != -1)
    {
        Booking *book = bookings[dateFound];

        CGPoint offset = CGPointMake(0, CELL_HEIGHT * dateFound + [self getIndexOfDateInSections:book.startDate] * 20);
        [self.table setContentOffset:offset animated:YES];
    }
    else
    {
        if(dates.count > 0)
        {
            Booking *book = bookings[bookings.count - dates.count];

            CGPoint offset = CGPointMake(0, CELL_HEIGHT * (bookings.count - dates.count) + [self getIndexOfDateInSections:book.startDate] * 20);
            [self.table setContentOffset:offset animated:YES];
        }
        
        
    }

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
        
        [UIView animateWithDuration:0.3 animations:^{
            
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


-(BOOL)checkIsBookForThisDateIsInSections:(NSDate *)date2check
{
    for(NSDate *date in sections)
    {
        if([self.calendar date:date2check isSameDayAsDate:date])
        {
            return YES;
        }
        
    }
    return NO;
}

-(void)splitBookings
{

    sections = [NSMutableArray new];
    
    for(Booking *book in bookings)
    {
        if(![self checkIsBookForThisDateIsInSections:book.startDate])
        {
            [sections addObject:book.startDate];
        }
       
    }
}


-(NSMutableArray *)getBookingsForDate:(NSDate *)date
{
    NSMutableArray *temp = [NSMutableArray new];
    for(Booking *book in bookings)
    {
        if([self.calendar date:date isSameDayAsDate:book.startDate])
        {
            [temp addObject:book];
        }
        
    }
    
    return temp;
}

-(void)showBookings
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    bookings = [Booking getFilteredRecordsWithSortedPredicate:predicate key:@"startDate" ascending:YES];
    [self splitBookings];
    
    [self.table reloadData];
    
    [self getDetailsStepByStep];


    
}

-(void)refreshSchedule
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    Person *person = [Person getSingleObjectByPredicate:predicate];
    [[DKAHTTPClient sharedManager] setUsername:person.personLogin andPassword:person.personPwd];
    [[DKAHTTPClient sharedManager] setParameterEncoding:AFJSONParameterEncoding];

    NSLog(@"%@ %@  %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"],person.personLogin, person.personPwd );
    
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
                book.desc = [[booking objectForKey:@"Booking"] objectForKey:@"Description"] == [NSNull null] ? @"" :[[booking objectForKey:@"Booking"] objectForKey:@"Description"];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                //[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
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


                if([[booking objectForKey:@"Booking"] objectForKey:@"PaidDateTime"] != [NSNull null])
                {
                    NSDate *paidDate = [dateFormat dateFromString:[[booking objectForKey:@"Booking"] objectForKey:@"PaidDateTime"]];
                    
                    book.paiDateTime = paidDate;
                }


            }
        }
        [Booking saveDefaultContext];
        
        [self showBookings];
        
         [refreshControl endRefreshing];
        
        [self scrollBookingsToDate:[NSDate date]];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

         [refreshControl endRefreshing];
    }];
    
    
   
    
}

-(void)getDetailsStepByStep
{
    Sequencer *sequencer = [[Sequencer alloc] init];
    int __block count = 0;
    for (Booking *book in bookings) {
        [sequencer enqueueStep:^(id result, SequencerCompletion completion)
         {
                 [[DKAHelper sharedInstance] getDetails:book completeBlock:^(BOOL result, NSError *error) {
                     if(!error)
                     {
                         [Booking saveDefaultContext];
                         
                         [[DKAHelper sharedInstance] getClient:book.clientID.integerValue completeBlock:^(BOOL result, NSError *error) {
                             [Client saveDefaultContext];
                             NSLog(@"Booking %@ and Client %@ received", book.bookingId, book.clientID);
                             count++;
                             if(count == bookings.count)
                             {
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"loading" object:nil userInfo:nil];
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];


                             }
                         }];
                     }
                     else
                     {
                         if(count == bookings.count)
                         {
                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                             
                             
                         }
                     }
                    
                 }];
                 completion([NSNumber numberWithBool:YES]);
         }];
    }
    [sequencer run];
   
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self getBookingsForDate:((NSDate *)sections[section])].count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([self getBookingsForDate:((NSDate *)sections[section])].count > 0) return 20;
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == (sections.count - 1))
        return 1;
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == (sections.count - 1))
    {
        UIView *empty = [[UIView alloc] initWithFrame:CGRectZero];
        return empty;
    }
    else
    {
        UIView *empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
        return empty;
        
    }
    
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSDate *date =  sections[section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    
    view.backgroundColor = MAIN_BACK_COLOR;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 20)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = TITLE_COLOR;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormat setDateFormat:@"EEEE, MMM dd"];
    
    
    lblTitle.text = [dateFormat stringFromDate:date];


   
    lblTitle.font = [UIFont boldSystemFontOfSize:13];
    [view addSubview:lblTitle];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BookingCell"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormat setDateFormat:@"EEEE, MMM dd"];
    Booking *book = nil;
    
    book = [self getBookingsForDate:((NSDate *)sections[indexPath.section])][indexPath.row];
    
    
    ((UILabel *)[cell.contentView viewWithTag:101]).text = book.clientName;
    
    /*NSCharacterSet *delimiterCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSArray *firstWords = [book.clientName componentsSeparatedByCharactersInSet:delimiterCharacterSet];

    if(firstWords.count > 1)
    {
        [((UILabel *)[cell.contentView viewWithTag:101]) boldSubstring: firstWords[1]];

    }*/
    
    ((UILabel *)[cell.contentView viewWithTag:102]).text = book.bookingTypeName;
    ((UILabel *)[cell.contentView viewWithTag:102]).textColor = GRAY_TEXT_COLOR;
    

    NSString *str = [dateFormat stringFromDate:book.startDate];
    ((UILabel *)[cell.contentView viewWithTag:103]).textColor = GRAY_TEXT_COLOR;
    if([self.calendar date:[NSDate date] isSameDayAsDate:book.startDate])
    {
        ((UILabel *)[cell.contentView viewWithTag:103]).textColor = TODAY_IN_LIST_COLOR;
    }

    if([book.startDate isToday])
    {
        ((UILabel *)[cell.contentView viewWithTag:103]).text = @"Today";
    }
    else
    {
        if([book.startDate isTomorrow])
        {
            ((UILabel *)[cell.contentView viewWithTag:103]).text = @"Tomorrow";
            
        }
        else
        {
            ((UILabel *)[cell.contentView viewWithTag:103]).text = str;

        }
    }
    
    
    [dateFormat setAMSymbol:@"am"];
    [dateFormat setPMSymbol:@"pm"];
    [dateFormat setDateFormat:@"hh:mma"];
    NSString *strHS = [dateFormat stringFromDate:book.startDate];
    NSString *strHE = [dateFormat stringFromDate:book.endDate];
    ((UILabel *)[cell.contentView viewWithTag:104]).textColor = GRAY_TEXT_COLOR;
    ((UILabel *)[cell.contentView viewWithTag:104]).text = [NSString stringWithFormat:@"%@ - %@", strHS, strHE];
    if([book.startDate isTomorrow])
    {
        ((UILabel *)[cell.contentView viewWithTag:103]).textColor = GREEN_TEXT_COLOR;
        ((UILabel *)[cell.contentView viewWithTag:104]).textColor = GREEN_TEXT_COLOR;

    }
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Booking *book = nil;
    book = [self getBookingsForDate:((NSDate *)sections[indexPath.section])][indexPath.row];

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
        if([date isEqualToDateIgnoringTime:book.startDate])
        {
            NSLog(@"%@   %@", date, book.startDate);
            dateItem.backgroundColor = MAIN_BACK_COLOR;
            dateItem.textColor = [UIColor darkTextColor];
            int i = 0;
            for(Booking *b in bookings)
            {
                if([book.startDate isEqualToDateIgnoringTime:b.startDate])
                {
                    i++;
                }
                
            }
            if(i>1)
            {
                dateItem.backgroundColor = CONFLICT_COLOR;
                dateItem.textColor = [UIColor darkTextColor];
            }
           
        }
        
    }
    
}

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    return YES;
}

-(NSInteger)getIndexOfDateInSections:(NSDate *)date2check
{
    int i = 0;
    for(NSDate *date in sections)
    {
        if([self.calendar date:date2check isSameDayAsDate:date])
        {
            return i;
        }
        i++;
    }
    
    return 0;
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    //self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    
    int i = 0;
    selectedDate = date;
    
    for(Booking *book in bookings)
    {
        if([self.calendar date:date isSameDayAsDate:book.startDate])
        {
            
            
            
            [self showCalendar:nil];
            
            
            CGPoint offset = CGPointMake(0, CELL_HEIGHT * i + [self getIndexOfDateInSections:date] * 20);
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
