//
//  DKABillingsVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/19/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKABillingsVC.h"
#import "Booking.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "BookingDetails.h"
#import "Client.h"
#import "ClientContactPerson.h"
#import "NSDate-Utilities.h"
#import "DKADefines.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+GetConstrain.h"
#import "DKAHelper.h"
#import "DKAHTTPClient.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
@interface DKABillingsVC ()
{
    NSMutableArray *bookings;
    CGRect contFrame;
    CGRect tableFrame;
}
@end

@implementation DKABillingsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAgain) name:@"loading" object:nil];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    bookings = [Booking getFilteredRecordsWithSortedPredicate:predicate key:@"startDate" ascending:YES];

    
    /*for (Booking *book in bookings) {
        

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookingID = %@", book.bookingId];
        BookingDetails *bd = [BookingDetails getSingleObjectByPredicate:predicate];
        
        NSLog(@"%@", bd.paidDateTime);
    }*/
    
    _btnFlag.hidden = YES;
    _lblMessage.hidden = YES;
    
    
    _btnFlag.layer.cornerRadius = 3;
    _btnFlag.backgroundColor = MAIN_ORANGE;
    [_btnFlag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    
    
    //[self showHidePanel:NO];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadAgain];
    [self placeControls];
    if([self.table indexPathsForSelectedRows].count > 0)
    {
        [self showHidePanel:YES];
    }

}


-(IBAction)flagAsPaid:(id)sender
{
    if([self.table indexPathsForSelectedRows].count > 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        
        NSArray *selected = [self.table indexPathsForSelectedRows];
        
        NSMutableArray *temp = [NSMutableArray new];
        
        for (NSIndexPath *index in selected) {
            
            Booking *booking = bookings[index.row];
            [temp addObject:booking.bookingId];
            booking.paiDateTime = [NSDate date];
            
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
        Person *person = [Person getSingleObjectByPredicate:predicate];
        [[DKAHTTPClient sharedManager] setUsername:person.personLogin andPassword:person.personPwd];
        [[DKAHTTPClient sharedManager] setParameterEncoding:AFJSONParameterEncoding];
        [[DKAHTTPClient sharedManager] postPath:@"/api/Booking/MarkBookingsAsPaid" parameters:@{@"Bookings":temp} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *response = [operation responseString];
            NSLog(@"response flagAsPaid :  [%@]",response);
            [Booking saveDefaultContext];
            [self loadAgain];
            [self showHidePanel:NO];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"response flagAsPaid error :  [%@]",error.description);
            [Booking resetDefaultContext];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }];
        
    }
}

-(void)showHidePanel:(BOOL)show
{
    if(show)
    {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect = tableFrame;
            rect.size.height = rect.size.height - 70;
            self.table.frame = rect;
            
            rect = contFrame;
            rect.origin.y = rect.origin.y - 70;
            self.container.frame = rect;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.4 animations:^{
            
            
            self.table.frame = tableFrame;
            self.container.frame = contFrame;
        }];
        
    }
}

-(void)placeControls
{
    if([[DKAHelper sharedInstance] isIphone5])
    {
        self.table.frame = CGRectMake(0, 0, 320, 465);
        self.container.frame = CGRectMake(0, 465, 320, 70);
        tableFrame = self.table.frame;
        contFrame = self.container.frame;
    }
    else
    {
        self.table.frame = CGRectMake(0, 0, 320, 376);
        self.container.frame = CGRectMake(0, 376, 320, 70);
        tableFrame = self.table.frame;
        contFrame = self.container.frame;
    }
    
    
    
    
}


-(void)loadAgain
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    bookings = [Booking getFilteredRecordsWithSortedPredicate:predicate key:@"startDate" ascending:YES];
    
    [self.table reloadData];
}

-(float)getTotalSumFromPaidBookings
{
    float sum = 0.0;

    for (Booking *book in bookings) {
        
        if(book.paiDateTime != nil)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookingID = %@", book.bookingId];
            BookingDetails *bd = [BookingDetails getSingleObjectByPredicate:predicate];
            
            int minutes = [bd.startDateTime minutesBeforeDate:bd.endDateTime];
            float totalHours = minutes / 60.0;
            
            sum = sum + (totalHours * bd.hourlyRate.floatValue + bd.orHours.floatValue * bd.otRate.floatValue);
        }
        
    }
    return sum;
}

-(float)getTotalSum
{
    float sum = 0.0;

    if([self.table indexPathsForSelectedRows].count > 0)
    {
        NSArray *selected = [self.table indexPathsForSelectedRows];
        
        for (NSIndexPath *index in selected) {
            
            Booking *booking = bookings[index.row];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookingID = %@", booking.bookingId];
            BookingDetails *bd = [BookingDetails getSingleObjectByPredicate:predicate];
            
            int minutes = [bd.startDateTime minutesBeforeDate:bd.endDateTime];
            float totalHours = minutes / 60.0;
            
            sum = sum + (totalHours * bd.hourlyRate.floatValue + bd.orHours.floatValue * bd.otRate.floatValue);
        }
        
    }
    
    return sum;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"billingCell"];
    cell = nil;
    if(cell == nil)
    {
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"billingCell"];
    }
    Booking *booking = [bookings objectAtIndex:indexPath.row];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookingID = %@", booking.bookingId];
    BookingDetails *bd = [BookingDetails getSingleObjectByPredicate:predicate];
    
    predicate = [NSPredicate predicateWithFormat:@"clientID = %@", bd.clientID];
    Client *client = [Client getSingleObjectByPredicate:predicate];
    
    if(bd != nil && client != nil)
    {
        //schedule
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormat setDateFormat:@"EEEE, MMM dd"];
        
        NSString *str = [dateFormat stringFromDate:bd.startDateTime];
        ((UILabel *)[cell.contentView viewWithTag:103]).text = str;
        [dateFormat setAMSymbol:@"am"];
        [dateFormat setPMSymbol:@"pm"];
        [dateFormat setDateFormat:@"hh:mma"];
        NSString *strHS = [dateFormat stringFromDate:bd.startDateTime];
        NSString *strHE = [dateFormat stringFromDate:bd.endDateTime];
        
        ((UILabel *)[cell.contentView viewWithTag:104]).text = bd.startDateTime == nil ? @"" : [NSString stringWithFormat:@"%@ - %@", strHS, strHE].uppercaseString;
        
        //name
        
        
        ((UILabel *)[cell.contentView viewWithTag:101]).text = [client.companyName uppercaseString];
        ((UILabel *)[cell.contentView viewWithTag:102]).text = bd.bookingTypeName;
        
        
        int minutes = [bd.startDateTime minutesBeforeDate:bd.endDateTime];
        
        float total = minutes / 60.0;
        
        ((UILabel *)[cell.contentView viewWithTag:105]).text = [NSString stringWithFormat:@"$%.2f", (total * bd.hourlyRate.floatValue + bd.orHours.floatValue * bd.otRate.floatValue)];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if([[self.table indexPathsForSelectedRows] containsObject:indexPath] && booking.paiDateTime == nil)
        {
            cell.contentView.backgroundColor = MAIN_BACK_COLOR;
            
        }
        else
        {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
        }
        [[cell.contentView viewWithTag:900] removeFromSuperview];
        [[cell.contentView viewWithTag:901] removeFromSuperview];

        if(booking.paiDateTime != nil)
        {

            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(305, 15, 8, 16)];
            imgView.tag = 900;
            imgView.backgroundColor = [UIColor clearColor];
            imgView.image = [UIImage imageNamed:@"1.png"];
            [cell.contentView addSubview:imgView];
        }
        else
        {
            [[cell.contentView viewWithTag:900] removeFromSuperview];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(305, 15, 8, 16)];
            imgView.tag = 901;
            imgView.backgroundColor = [UIColor clearColor];
            imgView.image = [UIImage imageNamed:@"2.png"];
            [cell.contentView addSubview:imgView];
        }
        
    }
    
   
    
    return cell;
}

-(void)showHideMessage
{
    float sum = [self getTotalSum];

    if(sum > 0.0)
    {
        _lblMessage.hidden = NO;
        _lblMessage.text = [NSString stringWithFormat:@"You have selected %i booking(s) for a total %.2f as paid", self.table.indexPathsForSelectedRows.count, sum];
        _btnFlag.hidden = NO;
        
        [self showHidePanel:YES];
    }
    else
    {
        _lblMessage.hidden = YES;
        _btnFlag.hidden = YES;
        [self showHidePanel:NO];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell  =[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    
    [self showHideMessage];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Booking *book = [bookings objectAtIndex:indexPath.row];
    if(book.paiDateTime == nil)
    {
        UITableViewCell *cell  =[tableView cellForRowAtIndexPath:indexPath];
        cell.selected = YES;
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;
        
        
        [self showHideMessage];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
   
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
