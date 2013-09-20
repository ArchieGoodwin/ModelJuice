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
@interface DKABillingsVC ()
{
    NSMutableArray *bookings;
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

    _btnFlag.hidden = YES;
    _lblMessage.hidden = YES;
    
    
    _btnFlag.layer.cornerRadius = 3;
    _btnFlag.backgroundColor = MAIN_ORANGE;
    [_btnFlag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
	// Do any additional setup after loading the view.
}

-(void)loadAgain
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    bookings = [Booking getFilteredRecordsWithSortedPredicate:predicate key:@"startDate" ascending:YES];
    
    [self.table reloadData];
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
        
        if([[self.table indexPathsForSelectedRows] containsObject:indexPath])
        {
            cell.contentView.backgroundColor = MAIN_BACK_COLOR;
            
        }
        else
        {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
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
    }
    else
    {
        _lblMessage.hidden = YES;
        _btnFlag.hidden = YES;
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
    UITableViewCell *cell  =[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
    cell.contentView.backgroundColor = MAIN_BACK_COLOR;
    
    
    [self showHideMessage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
