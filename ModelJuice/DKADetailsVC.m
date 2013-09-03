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
#import "Client.h"
#import "ClientContactPerson.h"
#import <MapKit/MapKit.h>
@interface DKADetailsVC ()
{
    int callTag;
}
@end

@implementation DKADetailsVC


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![self isIphone5])
    {
       // self.table.frame = CGRectMake(0, 44, 320, 280);
    }

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
    
    
    [self getDetails];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)btnMap:(id)sender {
    
    _currentClient.city = @"New York";
    _currentClient.addressLine1 = @"Central Park";
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        
        NSString *address = [NSString stringWithFormat:@"%@ %@ %@", _currentClient.city,  _currentClient.addressLine1,  _currentClient.addressLine2];
       
        
        [geocoder geocodeAddressString:address
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         // Convert the CLPlacemark to an MKPlacemark
                         // Note: There's no error checking for a failed geocode
                         CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc]
                                                   initWithCoordinate:geocodedPlacemark.location.coordinate
                                                   addressDictionary:geocodedPlacemark.addressDictionary];
                         
                         // Create a map item for the geocoded address to pass to Maps app
                         MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:geocodedPlacemark.name];
                         
                         // Set the directions mode to "Driving"
                         // Can use MKLaunchOptionsDirectionsModeWalking instead
                         NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                         
                         // Get the "Current User Location" MKMapItem
                         MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                         
                         // Pass the current location and destination map items to the Maps app
                         // Set the direction mode in the launchOptions dictionary
                         [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                         
                     }];
    }
    
}

- (IBAction)btnCall:(id)sender {
    UIButton *btn = (UIButton *)sender;
    _currentClient.phone = @"1111111";
    if(btn.tag == 230 && ![_currentClient.phone isEqualToString:@""])
    {
        callTag = 230;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to call to %@", _currentClient.phone] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
        [alert show];
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _currentClient.clientID];
    ClientContactPerson *clientPerson = [ClientContactPerson getSingleObjectByPredicate:predicate];
    clientPerson.workPhone = @"33333";
    if(clientPerson != nil)
    {
        if(btn.tag == 231 && ![clientPerson.workPhone isEqualToString:@""])
        {
            callTag = 231;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to call to %@", clientPerson.workPhone] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
            [alert show];
        }
    }
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if(callTag == 230)
        {
            NSLog(@"CALL PHONE %@", _currentClient.phone);
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", _currentClient.phone]];
            [[UIApplication sharedApplication] openURL:url];
            return;
        }
        if(callTag == 231)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _currentClient.clientID];
            ClientContactPerson *clientPerson = [ClientContactPerson getSingleObjectByPredicate:predicate];
            NSLog(@"CALL PHONE %@", clientPerson.workPhone);
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", clientPerson.workPhone]];
            [[UIApplication sharedApplication] openURL:url];
            return;
        }
       
    }
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
            

            NSLog(@"%@", [res objectForKey:@"ClientID"]);
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
            book.agencyName = [res objectForKey:@"AgencyName"] == [NSNull null] ? @"" : [res objectForKey:@"AgencyName"];

            book.bookingTypeID = [res objectForKey:@"BookingTypeID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"BookingTypeID"];
            book.bookingTypeName = [res objectForKey:@"BookingTypeName"] == [NSNull null] ? @"" : [res objectForKey:@"BookingTypeName"];

            book.clientContactID = [res objectForKey:@"ClientContactID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ClientContactID"];
            book.clientContactName = [res objectForKey:@"ClientContactName"] == [NSNull null] ? @"" : [res objectForKey:@"ClientContactName"];

            book.clientID = [res objectForKey:@"ClientID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ClientID"];
            book.clientName = [res objectForKey:@"ClientName"] == [NSNull null] ? @"" : [res objectForKey:@"ClientName"];

            book.hair = [res objectForKey:@"Hair"] == [NSNull null] ? @"" : [res objectForKey:@"Hair"];
            book.hourlyRate = [res objectForKey:@"HourlyRate"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"HourlyRate"];
            book.makeup = [res objectForKey:@"Makeup"] == [NSNull null] ? @"" : [res objectForKey:@"Makeup"];
            book.modelID = [res objectForKey:@"ModelID"] == [NSNull null] ? [NSNumber numberWithInt:0] : [res objectForKey:@"ModelID"];
            book.modelName = [res objectForKey:@"ModelName"] == [NSNull null] ? @"" : [res objectForKey:@"ModelName"];

            book.notes =  [res objectForKey:@"Notes"] == [NSNull null] ? @"" : [res objectForKey:@"Notes"];
            book.orHours = [res objectForKey:@"ORHours"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"ORHours"];
            book.otRate = [res objectForKey:@"OTRate"] == [NSNull null] ? [NSNumber numberWithFloat:0.0] : [res objectForKey:@"OTRate"];
            NSDate *paidDate = [res objectForKey:@"PaidDateTime"] == [NSNull null] ? [NSDate date] : [res objectForKey:@"PaidDateTime"];
            book.paidDateTime = paidDate;
            book.stylist = [res objectForKey:@"Stylist"] == [NSNull null] ? @"" : [res objectForKey:@"Stylist"];
            book.team = [res objectForKey:@"Team"] == [NSNull null] ? @"" : [res objectForKey:@"Team"];

            NSLog(@"%@", book.clientID);

            [BookingDetails saveDefaultContext];

            _bookingDetail = book;
            
            [self.table reloadData];
            
            [self getClient];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }];
    }
    else
    {
        _bookingDetail = bd;
        NSLog(@"%@", _bookingDetail.clientID);

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _bookingDetail.clientID];
        _currentClient = [Client getSingleObjectByPredicate:predicate];
        
        [self.table reloadData];
    }

}

-(void)getClient
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _bookingDetail.clientID];
    Client *client = [Client getSingleObjectByPredicate:predicate];

    if(client == nil)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
        Person *person = [Person getSingleObjectByPredicate:predicate];
        [[DKAHTTPClient sharedManager] setUsername:person.personLogin andPassword:person.personPwd];
        [[DKAHTTPClient sharedManager] getPath:@"/api/Client/GetClientDetails" parameters:@{@"Id": _booking.clientID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"success");
            NSLog(@"[getClient responseData]: %@",responseObject);
            
            NSDictionary *res = [[responseObject objectForKey:@"ReturnValue"] objectForKey:@"ClientDetails"];
            
            
            //NSLog(@"%@", res);
            Client *cli = [Client createEntityInContext];
            cli.clientID = [res objectForKey:@"ClientID"];
            cli.companyName = [res objectForKey:@"CompanyName"] == [NSNull null] ? @"" : [res objectForKey:@"CompanyName"];
            cli.phone = [res objectForKey:@"Phone"] == [NSNull null] ? @"" : [res objectForKey:@"Phone"];
            cli.addressLine1 = [res objectForKey:@"AddressLine1"] == [NSNull null] ? @"" : [res objectForKey:@"AddressLine1"];
            cli.addressLine2 = [res objectForKey:@"AddressLine2"] == [NSNull null] ? @"" : [res objectForKey:@"AddressLine2"];
            cli.city = [res objectForKey:@"City"] == [NSNull null] || [res objectForKey:@"City"] == nil ? @"11" : [res objectForKey:@"City"];
            cli.stateID = [res objectForKey:@"StateID"] == [NSNull null] ? [NSNumber numberWithInteger:0] : [res objectForKey:@"StateID"];
            cli.zipcode = [res objectForKey:@"Zipcode"] == [NSNull null] ? @"" : [res objectForKey:@"Zipcode"];
            NSLog(@"%@", cli.city);
            for(NSDictionary *det in [res objectForKey:@"ClientContacts"])
            {
                ClientContactPerson *cliPerson = [ClientContactPerson createEntityInContext];
                cliPerson.personID = [[det objectForKey:@"ClientContactPerson"] objectForKey:@"PersonID"];
                cliPerson.personFullName =  [[det objectForKey:@"ClientContactPerson"] objectForKey:@"PersonFullName"] == [NSNull null] ? @"" :  [[det objectForKey:@"ClientContactPerson"] objectForKey:@"PersonFullName"];
                cliPerson.workPhone =  [[det objectForKey:@"ClientContactPerson"] objectForKey:@"WorkPhone"] == [NSNull null] ? @"" :  [[det objectForKey:@"ClientContactPerson"] objectForKey:@"WorkPhone"];
                cliPerson.clientID = cli.clientID;

            }
            
            [Client saveDefaultContext];
            
            _currentClient = cli;
            
            [self.table reloadData];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }];
        
    }
    else
    {
        _currentClient = client;
        [self.table reloadData];
    }
    
    
    

    
}




-(BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                //NSLog(@"iPhone 4 Resolution");
                return NO;
            }
            if(result.height == 1136) {
                //NSLog(@"iPhone 5 Resolution");
                //[[UIScreen mainScreen] bounds].size =result;
                return YES;
            }
        }
        else{
            // NSLog(@"Standard Resolution");
            return NO;
        }
    }
    return NO;
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
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _currentClient.clientID];
        ClientContactPerson *clientPerson = [ClientContactPerson getSingleObjectByPredicate:predicate];
        
        if(clientPerson != nil)
        {
            ((UILabel *)[container viewWithTag:206]).text = [_currentClient.city isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@ %@", _currentClient.city, _currentClient.stateID];
            ((UILabel *)[container viewWithTag:207]).text =  [_currentClient.addressLine1 isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@, %@", _currentClient.addressLine1, _currentClient.addressLine2];
            
            ((UILabel *)[container viewWithTag:209]).text =  [clientPerson.personFullName isEqualToString:@""] ? @"" : clientPerson.personFullName;
            ((UILabel *)[container viewWithTag:210]).text =  [clientPerson.workPhone isEqualToString:@""] ? @"" : clientPerson.workPhone;

        }
        
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
        
        
        ((UILabel *)[container viewWithTag:201]).text = _bookingDetail.agencyName;
        ((UILabel *)[container viewWithTag:202]).text = _bookingDetail.bookingTypeName;
        ((UILabel *)[container viewWithTag:212]).text = _bookingDetail.team;
        ((UILabel *)[container viewWithTag:213]).text = _bookingDetail.hair;
        ((UILabel *)[container viewWithTag:214]).text = _bookingDetail.stylist;
        ((UILabel *)[container viewWithTag:215]).text = [NSString stringWithFormat:@"$%@ per hour", _bookingDetail.hourlyRate];

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
