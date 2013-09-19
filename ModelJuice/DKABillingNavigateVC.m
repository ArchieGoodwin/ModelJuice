//
//  DKABillingNavigateVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/19/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKABillingNavigateVC.h"
#import "DKADefines.h"
@implementation DKABillingNavigateVC


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = MAIN_ORANGE;
    //self.navigationBar.translucent = YES;
    
    [self preferredStatusBarStyle];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
