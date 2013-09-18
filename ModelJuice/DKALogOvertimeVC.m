//
//  DKALogOvertimeVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/16/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKALogOvertimeVC.h"
#import "DKADefines.h"
#import "DKADetailsVC.h"
#import "DKAHTTPClient.h"
#import "AFNetworking.h"
#import "Booking.h"
#import "BookingDetails.h"
@interface DKALogOvertimeVC ()
{
    UITextField *txtRate;
    UITextField *txtHours;
    UITextField *txtMinutes;
    UILabel *lblTotal;
    UIPickerView *picker;
    BOOL pickerShown;
}
@end

@implementation DKALogOvertimeVC

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
    
    self.table.backgroundColor = MAIN_BACK_COLOR;

    pickerShown = NO;
    
    
    
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    if(_details.orHours != nil && _details.orHours.floatValue > 0)
    {
        int hours = floorf(_details.orHours.floatValue);
        
        float integral;

        float fractional = modff(_details.orHours.floatValue, &integral);  // breaks a float into fractional and integral parts
        
        int minutes = 60 * fractional;
        
        
        txtHours.text = [NSString stringWithFormat:@"%i",hours];
        txtMinutes.text = [NSString stringWithFormat:@"%i", minutes];
        txtRate.text = [NSString stringWithFormat:@"%.2f", _details.otRate.floatValue];
        
        lblTotal.text = [NSString stringWithFormat:@"%.2f", [self calculateTotal]];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)saveOvertime:(id)sender
{
    //float total = txtTime.text.floatValue * txtRate.text.floatValue;
    //lblTotal.text = [NSString stringWithFormat:@"%.2f", total];
    
    if(lblTotal.text.floatValue > 0)
    {
        
        _details.orHours = [NSNumber numberWithFloat:[self getTotalTime]];
        _details.otRate = [NSNumber numberWithFloat:txtRate.text.floatValue];
        [BookingDetails saveDefaultContext];
        
        [self sendOvertimeLog];
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        DKADetailsVC *previousController = [viewControllers objectAtIndex:[viewControllers count] - 2];
        
        previousController.overtimeString = lblTotal.text;
        
        NSLog(@"%@  %@", previousController.overtimeString, lblTotal.text);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You need to fill all fields to continue" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    
}


-(void)sendOvertimeLog
{
    [[DKAHTTPClient sharedManager] setParameterEncoding:AFFormURLParameterEncoding];
    //[client setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
    
    //[client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringUserCheckins].length]];
    NSMutableURLRequest *request = [[DKAHTTPClient sharedManager] multipartFormRequestWithMethod:@"POST" path:@"/api/Booking/SetBookingOvertimeTimeAndRate" parameters:[NSDictionary dictionaryWithObjectsAndKeys:_booking.bookingId, @"BookingId", [NSString stringWithFormat:@"%f", [self getTotalTime]], @"OvertimeTime", txtRate.text, @"OvertimeRate", nil] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFileData:image name:jp.Title fileName:[NSString stringWithFormat:@"%@.jpg", dateString] mimeType:@"image/jpeg"];
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [operation responseString];
        NSLog(@"response sendOvertimeLog :  [%@]",response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] == 403){
            NSLog(@"sendOvertimeLog Failed");
            return;
        }
        NSLog(@"error: %@", [operation error]);
        
    }];
    
    [operation start];


}



#pragma mark - UITextField methods

-(void)hideAll
{
    [self hideKeyboard];
    if(pickerShown)
    {
        pickerShown = NO;
        [picker removeFromSuperview];
        [_table beginUpdates];
        [_table endUpdates];
    }
}

-(void)hideKeyboard
{
    [txtRate resignFirstResponder];
    [txtMinutes resignFirstResponder];
    [txtHours resignFirstResponder];
    
    
}

-(float)getTotalTime
{
    float hours = txtHours.text.floatValue;
    float minutes = 0.0;
    switch (txtMinutes.text.integerValue) {
        case 15:
            minutes = 0.25;
            break;
        case 30:
            minutes = 0.5;
            break;
        case 45:
            minutes = 0.75;
            break;
    }
    
    return hours + minutes;
}

-(float)calculateTotal
{
    
    float total = [self getTotalTime] * txtRate.text.floatValue;
    
    return total;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    //[textField resignFirstResponder];

    lblTotal.text = [NSString stringWithFormat:@"%.2f", [self calculateTotal]];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag == 502)
    {
        [textField resignFirstResponder];

        return YES;
        
    }
    if(textField.tag == 500 || textField.tag == 501)
    {
        if(pickerShown)
        {
            [picker removeFromSuperview];
        }
        [self hideKeyboard];
        
        [textField resignFirstResponder];
        pickerShown = YES;
        [_table beginUpdates];
        [_table endUpdates];
        [self showPickerFromTextField:textField cell:[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
        
        return NO;

    }
    return NO;

}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{

        [textField becomeFirstResponder];
        if(pickerShown)
        {
            pickerShown = NO;
            [picker removeFromSuperview];
        }
        [_table beginUpdates];
        [_table endUpdates];
        [textField selectAll:self];
  

}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtRate)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
    
    return YES;
}

#pragma mark - Picker methods

-(void)showPickerFromTextField:(UITextField *)textField cell:(UITableViewCell *)cell
{
 
    [self hideKeyboard];
    picker = [[UIPickerView alloc] init];
    

    [picker setDataSource: self];
    [picker setDelegate: self];
    
    [picker setFrame: CGRectMake(0, 80, cell.contentView.frame.size.width, 180)];
    
    picker.showsSelectionIndicator = YES;
    
    //[picker selectRow:2 inComponent:0 animated:YES];
    if(textField.tag == 500)
    {
        picker.tag = 100;
        

        [picker selectRow:floorf(txtHours.text.integerValue) inComponent:0 animated:YES];

    }
    else
    {
        picker.tag = 101;

        
        int minutes = txtMinutes.text.integerValue;
        switch (minutes) {
            case 0:
                [picker selectRow:0 inComponent:0 animated:YES];
                break;
            case 15:
                [picker selectRow:1 inComponent:0 animated:YES];
                break;
            case 30:
                [picker selectRow:2 inComponent:0 animated:YES];
                break;
            case 45:
                [picker selectRow:3 inComponent:0 animated:YES];
                break;
                
            default:
                break;
        }
            
       
    }
    
    [cell.contentView addSubview: picker];
}


// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (picker.tag) {
        case 100:
            return 10;
        case 101:
            return 4;
        default:
            break;
    }
    return 0;

}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (picker.tag) {
        case 100:
            return [NSString stringWithFormat:@"%i", row];
            break;
        case 101:
            switch (row) {
                case 0:
                    return @"0";
                case 1:
                    return @"15";
                case 2:
                    return @"30";
                case 3:
                    return @"45";
                    
                default:
                    break;
            }
        default:
            break;
    }
    return @"";
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    pickerShown = NO;
    NSLog(@"You selected this row: %i", row);
    if(pickerView.tag == 100)
    {
        txtHours.text = [NSString stringWithFormat:@"%i", row];
    }
    if(pickerView.tag == 101)
    {
        switch (row) {
            case 0:
                txtMinutes.text = @"0";
                break;
            case 1:
                txtMinutes.text = @"15";
                break;
            case 2:
                txtMinutes.text = @"30";
                break;
            case 3:
                txtMinutes.text = @"45";
                break;
            
            default:
                break;
        }
    }
    
    [pickerView removeFromSuperview];
    [_table beginUpdates];
    [_table endUpdates];
    
    
    lblTotal.text = [NSString stringWithFormat:@"%.2f", [self calculateTotal]];

    //[self.table reloadData];

    

}

#pragma mark - Table view data source

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideAll];
}



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
    switch (indexPath.row) {
        case 0:
        {
            if(pickerShown)
            {
                return 270;
            }
            else
            {
                return 90;
            }
        }
        case 1:
        case 2:
            return 60;
            
        default:
            break;
    }
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"logOvertimeTimeCell"];
    
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"logOvertimeTimeCell"];
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;
        txtHours = (UITextField *)[cell.contentView viewWithTag:500];
        txtHours.delegate = self;
        txtHours.tintColor = MAIN_ORANGE;
        txtMinutes = (UITextField *)[cell.contentView viewWithTag:501];
        txtMinutes.delegate = self;
        txtMinutes.tintColor = MAIN_ORANGE;
        
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:499];
        [btn addTarget:self action:@selector(hideAll) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    }
    
    if(indexPath.row == 1)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"logOvertimeRateCell"];
        txtRate = (UITextField *)[cell.contentView viewWithTag:502];
        txtRate.delegate = self;
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;
        txtRate.tintColor = MAIN_ORANGE;

        return cell;
        
    }
    
    if(indexPath.row == 2)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"logOvertimeTotalCell"];
        lblTotal = (UILabel *)[cell.contentView viewWithTag:503];
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;
        
        return cell;
        
    }
    
    
    cell.contentView.backgroundColor = MAIN_BACK_COLOR;
    
    
    // Configure the cell...
    return cell;
}


@end
