//
//  DKALoginVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 8/29/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKALoginVC.h"
#import <QuartzCore/QuartzCore.h>
#import "DKANetworkHelper.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "Person.h"
#import "Booking.h"
#import "BookingDetails.h"
#import "Client.h"
#import "ClientContactPerson.h"
#import "DKADefines.h"
@interface DKALoginVC ()
{
    UITextField *loginTxt;
    UITextField *pwdTxt;
    BOOL rememberMe;
}
@end

@implementation DKALoginVC

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    rememberMe = NO;
    
    self.navigationController.navigationBarHidden = YES;
    [self preferredStatusBarStyle];

    self.table.backgroundColor = MAIN_BACK_COLOR;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"rememberMe"] isEqualToString:@"YES"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"PersonID"] != nil)
    {

        [self performSegueWithIdentifier:@"startMe" sender:nil];



    }

    //_btnRegister.layer.cornerRadius = 3;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [loginTxt resignFirstResponder];
    [pwdTxt resignFirstResponder];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        loginTxt = textField;
    }
    if(textField.tag == 2)
    {
        pwdTxt = textField;
    }

    CGPoint offset = CGPointMake(0, 120);
    [self.table setContentOffset:offset animated:YES];
}

- (IBAction)registerMe:(id)sender {
    
    if(loginTxt && pwdTxt)
    {
        if(loginTxt.text.length > 0 && pwdTxt.text.length > 0)
        {
            
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"PersonID"];
            
            for(Booking *book in [Booking getAllRecords])
            {
                [Booking deleteInContext:book];
            }
            for(BookingDetails *book in [BookingDetails getAllRecords])
            {
                [BookingDetails deleteInContext:book];
            }
            for(Person *book in [Person getAllRecords])
            {
                [Person deleteInContext:book];
            }
            for(Client *book in [Client getAllRecords])
            {
                [Client deleteInContext:book];
            }
            for(ClientContactPerson *book in [ClientContactPerson getAllRecords])
            {
                [ClientContactPerson deleteInContext:book];
            }
            
            [Booking saveDefaultContext];
            
            [[DKANetworkHelper sharedInstance] loginMe:loginTxt.text pwd:pwdTxt.text completeBlock:^(Person *result, NSError *error) {
                if(!error)
                {
                    NSLog(@"success login");

                    [self performSegueWithIdentifier:@"startMe" sender:nil];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            }];
            
            return;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"You should enter username and password to continue" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(IBAction)changeState:(id)sender
{
    UIButton *btn = (UIButton *)sender;

    if(!rememberMe)
    {
        
        [btn setImage:[UIImage imageNamed:@"CheckBox_Checked.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"rememberMe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else
    {
        [btn setImage:[UIImage imageNamed:@"CheckBox.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"rememberMe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    rememberMe = !rememberMe;
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
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 155;
        case 1:
        case 2:
            return 70;
        case 3:
            return 50;
        case 4:
            return 133;
            
        default:
            break;
    }
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LogoLoginCell"];

    if(indexPath.row == 0)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LogoLoginCell"];
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;

        return cell;

    }
    
    if(indexPath.row == 1)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LoginUserName"];
        loginTxt = (UITextField *)cell.contentView.subviews[1];
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;

        return cell;
        
    }
    
    if(indexPath.row == 2)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LoginPassword"];
        pwdTxt = (UITextField *)cell.contentView.subviews[1];
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;

        return cell;
        
    }
    
    if(indexPath.row == 3)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LoginRemember"];
        
        UIButton *btn = (UIButton *)cell.contentView.subviews[1];
        
        [btn addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;

        return cell;
        
    }
    
    if(indexPath.row == 4)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LoginButton"];
        
        UIButton *btn = cell.contentView.subviews[0];
        btn.layer.cornerRadius = 3;
        btn.backgroundColor = MAIN_ORANGE;
        cell.contentView.backgroundColor = MAIN_BACK_COLOR;

        
        return cell;
        
    }
    
    cell.contentView.backgroundColor = MAIN_BACK_COLOR;
    
    
    // Configure the cell...
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
