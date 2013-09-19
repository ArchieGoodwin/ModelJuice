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
#import "DKAHelper.h"
#import "DKAVoucherVC.h"
#import "DKALogOvertimeVC.h"
@interface DKADetailsVC ()
{
    int callTag;
}
@end

@implementation DKADetailsVC


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    [self getDetails];

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
    
    self.table.backgroundColor = MAIN_BACK_COLOR;
    self.view.backgroundColor = MAIN_BACK_COLOR;
    
    
    /* _currentClient.phone = @"1111111";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _currentClient.clientID];
    ClientContactPerson *clientPerson = [ClientContactPerson getSingleObjectByPredicate:predicate];
    clientPerson.workPhone = @"33333";
    _currentClient.city = @"New York";
    _currentClient.addressLine1 = @"Riverside Drive";
    _currentClient.addressLine2 = @"1";

    [self.table reloadData];*/
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (IBAction)btnCreateVoucher:(id)sender {
    
    [self performSegueWithIdentifier:@"createVoucher" sender:sender];
}

- (IBAction)btnLogOvertime:(id)sender {
    
    [self performSegueWithIdentifier:@"logOvertime" sender:sender];

}


- (IBAction)btnMap:(id)sender {
    

    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@", _currentClient.city, _currentClient.stateName,  _currentClient.addressLine1,  _currentClient.addressLine2];
        
        [geocoder geocodeAddressString:address
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc]
                                                   initWithCoordinate:geocodedPlacemark.location.coordinate
                                                   addressDictionary:geocodedPlacemark.addressDictionary];
                         
                         MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:geocodedPlacemark.name];
                         
                         // Set the directions mode to "Driving"
                         // Can use MKLaunchOptionsDirectionsModeWalking instead
                         //NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                         
                         //MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                         

                         [MKMapItem openMapsWithItems:@[ mapItem] launchOptions:nil];
                         
                     }];
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createVoucher"]) {
        
        DKAVoucherVC *controller = segue.destinationViewController;
        controller.booking = self.booking;
        controller.details = self.bookingDetail;
        controller.client = self.currentClient;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _currentClient.clientID];
        ClientContactPerson *clientPerson = [ClientContactPerson getSingleObjectByPredicate:predicate];
        
        controller.clientPerson = clientPerson;
        
        controller.overtimeString = self.overtimeString;
    }
    if([segue.identifier isEqualToString:@"logOvertime"])
    {
        DKALogOvertimeVC *controller = segue.destinationViewController;
        controller.booking = self.booking;
        controller.details = self.bookingDetail;
        controller.client = self.currentClient;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _currentClient.clientID];
        ClientContactPerson *clientPerson = [ClientContactPerson getSingleObjectByPredicate:predicate];
        
        controller.clientPerson = clientPerson;
        
    }
}

- (IBAction)btnCall:(id)sender {
    UIButton *btn = (UIButton *)sender;
   
    if(btn.tag == 230 && ![_currentClient.phone isEqualToString:@""])
    {
        callTag = 230;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to call to %@", _currentClient.phone] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
        [alert show];
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _currentClient.clientID];
    ClientContactPerson *clientPerson = [ClientContactPerson getSingleObjectByPredicate:predicate];
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
    [[DKAHTTPClient sharedManager] setParameterEncoding:AFJSONParameterEncoding];
    NSLog(@"bookingID = %@", _booking.bookingId);
    predicate = [NSPredicate predicateWithFormat:@"bookingID = %@", _booking.bookingId];
    BookingDetails *bd = [BookingDetails getSingleObjectByPredicate:predicate];
    if(bd == nil)
    {
        
        [[DKAHelper sharedInstance] getDetails:_booking completeBlock:^(BOOL result, NSError *error) {
            [BookingDetails saveDefaultContext];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookingID = %@", _booking.bookingId];
            BookingDetails *bd = [BookingDetails getSingleObjectByPredicate:predicate];
            _bookingDetail = bd;
            
            
            [[DKAHelper sharedInstance] getClient:_bookingDetail.clientID.integerValue completeBlock:^(BOOL result, NSError *error) {
                [Client saveDefaultContext];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _bookingDetail.clientID];
                Client *client = [Client getSingleObjectByPredicate:predicate];
                
                
                _currentClient = client;
                
                [self.table reloadData];

            }];
        }];
        

    }
    else
    {
        _bookingDetail = bd;
        NSLog(@"clientID %@", _bookingDetail.clientID);

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _bookingDetail.clientID];
        _currentClient = [Client getSingleObjectByPredicate:predicate];
        
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
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailsCell"];
        UIView *container = cell.contentView.subviews[0];
        float height = [[DKAHelper sharedInstance] getLabelSize:_bookingDetail.notes font:((UILabel *)[container viewWithTag:211]).font width:((UILabel *)[container viewWithTag:211]).frame.size.width];
        
        if(height > 48)
        {
            return (350 + (height - 48));
        }
        return 350;
    }
    if(indexPath.row == 1)
    {
        return  50;
    }

    if(indexPath.row == 2)
    {
        return 50;
    }

    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailsCell"];
    
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailsCell"];
        UIView *container = cell.contentView.subviews[0];

        UIView *cont = [[UIView alloc] initWithFrame:container.frame];
        cont.backgroundColor = [UIColor whiteColor];
        
        [cell.contentView addSubview:cont];
        [cell.contentView sendSubviewToBack:cont];
        
        if(_bookingDetail && _currentClient)
        {
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID = %@", _currentClient.clientID];
            ClientContactPerson *clientPerson = [ClientContactPerson getSingleObjectByPredicate:predicate];
            
            if(clientPerson != nil)
            {
                ((UILabel *)[container viewWithTag:206]).text = [_currentClient.city isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@, %@", _currentClient.city, _currentClient.stateName];
                ((UILabel *)[container viewWithTag:207]).text =  [_currentClient.addressLine1 isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@, %@", _currentClient.addressLine1, _currentClient.addressLine2];
                ((UILabel *)[container viewWithTag:203]).text =  [_currentClient.phone isEqualToString:@""] ? @"" : _currentClient.phone;
                
                ((UILabel *)[container viewWithTag:209]).text =  [clientPerson.personFullName isEqualToString:@""] ? @"" : [clientPerson.personFullName uppercaseString];
                ((UILabel *)[container viewWithTag:210]).text =  [clientPerson.workPhone isEqualToString:@""] ? @"" : clientPerson.workPhone;
                
            }
            
            cont.layer.cornerRadius = 5;
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            [dateFormat setDateFormat:@"EEEE, MMM dd, yyyy"];
            
            NSString *str = [dateFormat stringFromDate:_bookingDetail.startDateTime];
            ((UILabel *)[container viewWithTag:204]).text = str.uppercaseString;
            [dateFormat setAMSymbol:@"am"];
            [dateFormat setPMSymbol:@"pm"];
            [dateFormat setDateFormat:@"hh:mma"];
            NSString *strHS = [dateFormat stringFromDate:_bookingDetail.startDateTime];
            NSString *strHE = [dateFormat stringFromDate:_bookingDetail.endDateTime];
            
            ((UILabel *)[container viewWithTag:205]).text = [NSString stringWithFormat:@"%@ - %@", strHS, strHE].uppercaseString;
            
            
            ((UILabel *)[container viewWithTag:201]).text = [_currentClient.companyName uppercaseString];
            ((UILabel *)[container viewWithTag:202]).text = _bookingDetail.bookingTypeName;
            ((UILabel *)[container viewWithTag:230]).text = _bookingDetail.desc;

            //((UILabel *)[container viewWithTag:212]).text = _bookingDetail.team;
            //((UILabel *)[container viewWithTag:213]).text = _bookingDetail.hair;
            //((UILabel *)[container viewWithTag:214]).text = _bookingDetail.stylist;
            
            NSLog(@"%@", _bookingDetail.notes);
            ((UILabel *)[container viewWithTag:211]).text = _bookingDetail.notes;
            
    
            if(_bookingDetail.orHours != nil && _bookingDetail.orHours.floatValue > 0)
            {
                ((UILabel *)[container viewWithTag:215]).text = [NSString stringWithFormat:@"Details  $%@/hour  (overtime: %.2f$)", _bookingDetail.hourlyRate, _bookingDetail.orHours.floatValue * _bookingDetail.otRate.floatValue];

            }
            else
            {
                ((UILabel *)[container viewWithTag:215]).text = [NSString stringWithFormat:@"Details  $%@/hour", _bookingDetail.hourlyRate];

            }

            float height = [[DKAHelper sharedInstance] getLabelSize:_bookingDetail.notes font:((UILabel *)[container viewWithTag:211]).font width:((UILabel *)[container viewWithTag:211]).frame.size.width];
            
            if(height > 48)
            {
                CGRect frame =((UILabel *)[container viewWithTag:211]).frame;
                frame.size.height = height;
                ((UILabel *)[container viewWithTag:211]).frame = frame;
                ((UILabel *)[container viewWithTag:211]).hidden = YES;
                UILabel *lblTeam = [[UILabel alloc] initWithFrame:frame];
                lblTeam.text = _bookingDetail.notes;
                lblTeam.font =((UILabel *)[container viewWithTag:211]).font;
                lblTeam.numberOfLines = 0;
                lblTeam.lineBreakMode = NSLineBreakByWordWrapping;
                [container addSubview:lblTeam];
                
                frame =((UILabel *)[container viewWithTag:215]).frame;
                frame.origin.y = frame.origin.y + (height - 48);
                ((UILabel *)[container viewWithTag:215]).frame = frame;
                ((UILabel *)[container viewWithTag:215]).hidden = YES;

                UILabel *lblRate = [[UILabel alloc] initWithFrame:frame];
                lblRate.text = ((UILabel *)[container viewWithTag:215]).text;
                lblRate.font =((UILabel *)[container viewWithTag:215]).font;
                [container addSubview:lblRate];
                
                
                frame = cont.frame;
                frame.size.height = (350 + (height - 48) - 10);
                cont.frame = frame;
                
            }
            
            
            
            
        }
        
        
        ((UIView *)[container viewWithTag:240]).backgroundColor = SEPARATOR_COLOR;
        ((UIView *)[container viewWithTag:241]).backgroundColor = SEPARATOR_COLOR;

        cell.contentView.backgroundColor = MAIN_BACK_COLOR;
        return cell;
        
    }
    
    if(indexPath.row == 1)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CreateVaucherCell"];
        UIButton *btn = cell.contentView.subviews[0];
        btn.layer.cornerRadius = 5;
        btn.backgroundColor = MAIN_ORANGE;
        
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;
        return cell;
        
    }
    
    if(indexPath.row == 2)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LogOvertimeCell"];
        UIButton *btn = cell.contentView.subviews[0];
        btn.layer.cornerRadius = 5;
        btn.backgroundColor = MAIN_ORANGE;
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;
        return cell;
        
    }
    
    return cell;
}


@end
