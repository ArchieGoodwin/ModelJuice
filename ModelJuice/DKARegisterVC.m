//
//  DKARegisterVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/25/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKARegisterVC.h"
#import "DKADefines.h"
@interface DKARegisterVC ()

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
    
    self.view.backgroundColor = MAIN_ORANGE;
    
    NSURL* nsUrl = [NSURL URLWithString:REGISTER_URL];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl];

    [_webView loadRequest:request];
    
	
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", request.URL);
    
    if([request.URL isEqual:[NSURL URLWithString:BASE_URL_]])
    {
        
        NSLog(@"cancel");

        [self dismissViewControllerAnimated:YES completion:nil];
        
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
