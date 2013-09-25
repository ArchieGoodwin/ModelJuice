//
//  DKALoginVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 8/29/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKALoginVC.h"
#import <QuartzCore/QuartzCore.h>
#import "DKAHelper.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "Person.h"
#import "Booking.h"
#import "BookingDetails.h"
#import "Client.h"
#import "ClientContactPerson.h"
#import "DKADefines.h"
#import "MBProgressHUD.h"
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
- (IBAction)btnRegister:(id)sender {
    
    [self performSegueWithIdentifier:@"registerUser" sender:self];
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
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];

            
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
            
            [[DKAHelper sharedInstance] loginMe:loginTxt.text pwd:pwdTxt.text completeBlock:^(Person *result, NSError *error) {
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

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
        
        [btn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"rememberMe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else
    {
        [btn setImage:[UIImage imageNamed:@"check-box.png"] forState:UIControlStateNormal];
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
    return 6;
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
            return 50;
        case 5:
            return 50;
            
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
    if(indexPath.row == 5)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellRegister"];
        
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



@end
