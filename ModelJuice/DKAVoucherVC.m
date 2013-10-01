//
//  DKAVoucherVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/16/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKAVoucherVC.h"
#import "NISignatureViewQuartzQuadratic.h"
#import "DKADefines.h"
#import "Person.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "DKADetailsVC.h"
#import "DKAHTTPClient.h"
#import "AFNetworking.h"
#import "NSDate-Utilities.h"
#import "MBProgressHUD.h"
@interface DKAVoucherVC ()
{
    NISignatureViewQuartzQuadratic *sign;
}
@end

@implementation DKAVoucherVC

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
    
    sign = [[NISignatureViewQuartzQuadratic alloc] initWithFrame:CGRectMake(0, 0, 310, 100)];
    sign.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = MAIN_BACK_COLOR;
    self.container.backgroundColor = MAIN_BACK_COLOR;
    [self.container addSubview:sign];
    self.backView.backgroundColor = MAIN_BACK_COLOR;
    
    [self showDetails];
    
    
    
    
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    if(_booking.singing != nil)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:_booking.singing]];
        imgView.frame = sign.frame;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.userInteractionEnabled = YES;
        imgView.tag = 800;
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearSign)];
        [doubleTap setNumberOfTapsRequired:2];
        [imgView addGestureRecognizer:doubleTap];

        [self.container addSubview:imgView];
    }
}

-(void)clearSign
{
    UIView *imgView = [self.container viewWithTag:800];
    if(imgView != nil)
    {
        [imgView removeFromSuperview];
    }
}

-(IBAction)btnSave:(id)sender
{
    
    UIGraphicsBeginImageContextWithOptions(sign.bounds.size, sign.opaque, 4);
    [sign.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [_booking setSinging:UIImagePNGRepresentation(img)];
    
    [Booking saveDefaultContext];
    
    [self sendVoucher];
    //NSArray *viewControllers = self.navigationController.viewControllers;
    //DKADetailsVC *previousController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

-(void)sendVoucher
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[DKAHTTPClient sharedManager] setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddyyyyhhmmss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    
    //[client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringUserCheckins].length]];
    NSMutableURLRequest *request = [[DKAHTTPClient sharedManager] multipartFormRequestWithMethod:@"POST" path:@"/api/Booking/SaveBookingVoucher" parameters:[NSDictionary dictionaryWithObjectsAndKeys:_booking.bookingId, @"BookingId", nil] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:_booking.singing name:@"VoucherFile" fileName:[NSString stringWithFormat:@"%@.png", dateString] mimeType:@"image/png"];
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [operation responseString];
        NSLog(@"response sendVoucher :  [%@]",response);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"sendVoucher error: %@", [operation error]);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];
    
    [operation start];
    
    
}

-(float)getTotalTime
{
    int minutes = [_details.startDateTime minutesBeforeDate:_details.endDateTime];
    
    float total = minutes / 60.0;
    
    return total;
}

-(void)showDetails
{
    if(_details && _client)
    {
        
        
        
        if(_clientPerson != nil)
        {
            ((UILabel *)[self.view viewWithTag:206]).text = [_client.city isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@, %@", _client.city, _client.stateName];
            ((UILabel *)[self.view viewWithTag:207]).text =  [_client.addressLine1 isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@, %@", _client.addressLine1, _client.addressLine2];
            ((UILabel *)[self.view viewWithTag:203]).text =  [_client.phone isEqualToString:@""] ? @"" : _client.phone;
            
            ((UILabel *)[self.view viewWithTag:209]).text =  [_clientPerson.personFullName isEqualToString:@""] ? @"" : [_clientPerson.personFullName uppercaseString];
            ((UILabel *)[self.view viewWithTag:210]).text =  [_clientPerson.workPhone isEqualToString:@""] ? @"" : _clientPerson.workPhone;
            
        }
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"]];
        Person *person = [Person getSingleObjectByPredicate:predicate];
        ((UILabel *)[self.view viewWithTag:209]).text =  [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormat setDateFormat:@"EEEE, MMM dd, yyyy"];
        
        NSString *str = [dateFormat stringFromDate:_details.startDateTime];
        ((UILabel *)[self.view viewWithTag:204]).text = str;
        [dateFormat setAMSymbol:@"am"];
        [dateFormat setPMSymbol:@"pm"];
        [dateFormat setDateFormat:@"hh:mma"];
        NSString *strHS = [dateFormat stringFromDate:_details.startDateTime];
        NSString *strHE = [dateFormat stringFromDate:_details.endDateTime];
        
        ((UILabel *)[self.view viewWithTag:205]).text = [NSString stringWithFormat:@"from %@ to %@", strHS, strHE];
        
        
        ((UILabel *)[self.view viewWithTag:201]).text = [_client.companyName uppercaseString];
        ((UILabel *)[self.view viewWithTag:202]).text = _details.bookingTypeName;

        
        if(_details.orHours != nil && _details.orHours.floatValue > 0)
        {
            ((UILabel *)[self.view viewWithTag:215]).text = [NSString stringWithFormat:@"Details  $%@/hour  (overtime: %.2f$)", _details.hourlyRate, _details.orHours.floatValue * _details.otRate.floatValue];
            
        }
        else
        {
            ((UILabel *)[self.view viewWithTag:215]).text = [NSString stringWithFormat:@"Details  $%@/hour", _details.hourlyRate];
            
        }
        
        ((UILabel *)[self.view viewWithTag:220]).text = [NSString stringWithFormat:@"Total hours: %.2f", [self getTotalTime]];
        
        ((UILabel *)[self.view viewWithTag:221]).text = [NSString stringWithFormat:@"Total: $%.2f", ([self getTotalTime] * _details.hourlyRate.floatValue + _details.orHours.floatValue * _details.otRate.floatValue)];

        
        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
