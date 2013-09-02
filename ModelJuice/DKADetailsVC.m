//
//  DKADetailsVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/2/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKADetailsVC.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "Person.h"
#import "DKADefines.h"
#import "DKAHTTPClient.h"
#import "Booking.h"
#import "BookingDetails.h"
@interface DKADetailsVC ()

@end

@implementation DKADetailsVC


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self getDetails];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)getDetails
{

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
    Person *person = [Person getSingleObjectByPredicate:predicate];
    [[DKAHTTPClient sharedManager] setUsername:person.personLogin andPassword:person.personPwd];
    
    predicate = [NSPredicate predicateWithFormat:@"bookingID = %@", _booking.bookingId];
    BookingDetails *bd = [BookingDetails getSingleObjectByPredicate:predicate];
    if(bd == nil)
    {
        [[DKAHTTPClient sharedManager] getPath:@"/Api/Booking/GetBookingDetails" parameters:@{@"Id": _booking.bookingId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"success");
            NSLog(@"[getDetails responseData]: %@",responseObject);
            
            NSDictionary *res = [[responseObject objectForKey:@"ReturnValue"] objectForKey:@"BookingDetails"];
            

            //NSLog(@"%@", res);
            BookingDetails *book = [BookingDetails createEntityInContext];
            book.bookingID = [res objectForKey:@"BookingID"];
            book.desc = [res objectForKey:@"Description"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *startDate = [dateFormat dateFromString:[res objectForKey:@"StartDateTime"]];
            book.startDateTime = startDate;
            NSDate *endDate = [dateFormat dateFromString:[res objectForKey:@"EndDateTime"]];
            book.endDateTime = endDate;
            book.agencyID = [res objectForKey:@"AgencyID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"AgencyID"];
            book.bookingTypeID = [res objectForKey:@"BookingTypeID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"BookingTypeID"];
            book.clientContactID = [res objectForKey:@"ClientContactID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ClientContactID"];
            book.clientID = [res objectForKey:@"ClientID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ClientID"];
            book.hair = [res objectForKey:@"Hair"] == [NSNull null] ? @"" : [res objectForKey:@"Hair"];
            book.hourlyRate = [res objectForKey:@"HourlyRate"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"HourlyRate"];
            book.makeup = [res objectForKey:@"Makeup"] == [NSNull null] ? @"" : [res objectForKey:@"Makeup"];
            book.modelID = [res objectForKey:@"ModelID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ModelID"];
            book.notes =  [res objectForKey:@"Notes"] == [NSNull null] ? @"" : [res objectForKey:@"Notes"];
            book.orHours = [res objectForKey:@"ORHours"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"ORHours"];
            book.otRate = [res objectForKey:@"OTRate"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"OTRate"];
            NSDate *paidDate = [res objectForKey:@"PaidDateTime"] == [NSNull null] ? [NSDate date] : [res objectForKey:@"PaidDateTime"];
            book.paidDateTime = paidDate;
            book.stylist = [res objectForKey:@"Stylist"] == [NSNull null] ? @"" : [res objectForKey:@"Stylist"];
            book.team = [res objectForKey:@"Team"] == [NSNull null] ? @"" : [res objectForKey:@"Team"];


            [BookingDetails saveDefaultContext];

            _bookingDetail = book;
            
            [self.table reloadData];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }];
    }
    else
    {
        _bookingDetail = bd;
        [self.table reloadData];
    }
    
   
        
        
        
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 350;
    }
    if(indexPath.row == 1)
    {
        return  40;
    }

    if(indexPath.row == 0)
    {
        return 40;
    }

    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailsCell"];
    
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailsCell"];
        UIView *container = cell.contentView.subviews[0];
        
        container.layer.cornerRadius = 3;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormat setDateFormat:@"EEEE, MMM dd, yyyy"];
        
        NSString *str = [dateFormat stringFromDate:_bookingDetail.startDateTime];
        ((UILabel *)[container viewWithTag:204]).text = str;
        
        [dateFormat setDateFormat:@"hh:mma"];
        NSString *strHS = [dateFormat stringFromDate:_bookingDetail.startDateTime];
        NSString *strHE = [dateFormat stringFromDate:_bookingDetail.endDateTime];
        
        ((UILabel *)[container viewWithTag:205]).text = [NSString stringWithFormat:@"from %@ to %@", strHS, strHE];
        
        
        return cell;
        
    }
    
    if(indexPath.row == 1)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CreateVaucherCell"];
        UIButton *btn = cell.contentView.subviews[0];
        btn.layer.cornerRadius = 3;
        return cell;
        
    }
    
    if(indexPath.row == 2)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LogOvertimeCell"];
        UIButton *btn = cell.contentView.subviews[0];
        btn.layer.cornerRadius = 3;
        return cell;
        
    }
    
    return cell;
}


@end
