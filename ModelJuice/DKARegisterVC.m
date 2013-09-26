//
//  DKARegisterVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/25/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKARegisterVC.h"
#import "DKADefines.h"
#import "MBProgressHUD.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "Person.h"
#import "Booking.h"
#import "BookingDetails.h"
#import "Client.h"
#import "ClientContactPerson.h"
#import "DKAHelper.h"
#import "DKALoginVC.h"
@interface DKARegisterVC ()
{
    NSInteger steps;

}
@end

@implementation DKARegisterVC

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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    self.view.backgroundColor = MAIN_ORANGE;
    
    NSURL* nsUrl = [NSURL URLWithString:REGISTER_URL];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl];
    
    [_webView loadRequest:request];
    
	
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSString *initScript = [NSString stringWithFormat:@"registerAppHandler()"];
    NSString *valueValidate = [_webView stringByEvaluatingJavaScriptFromString:initScript];


}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@  %@", request.URL.scheme, request.URL.host);
    NSString *scheme = request.URL.scheme;
    NSString *host = request.URL.host;
    
    if([scheme isEqualToString:@"modeljuice"])
    {
        if([host isEqualToString:@"cancelregistration"])
        {
            NSLog(@"cancel");
            
            [self dismissViewControllerAnimated:YES completion:^{
                
              
                
            }];
        }
        if([host isEqualToString:@"savecredentials"])
        {

            NSDictionary *params = [[DKAHelper sharedInstance] splitQuery:request.URL.query];
            
            _login = [params objectForKey:@"email"];
            _pwd = [params objectForKey:@"password"];
            
            NSLog(@"%@ %@", _login, _pwd);
            

            
        }
        if([host isEqualToString:@"registrationsuccess"])
        {
            
            [self performSegueWithIdentifier:@"backToLogin" sender:nil];

            
            //[self dismissViewControllerAnimated:YES completion:^{
                
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have been successfully registered. You may use your login and password to logon." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
                
            //}];
        }
        
       
        
        return NO;
    }

    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
