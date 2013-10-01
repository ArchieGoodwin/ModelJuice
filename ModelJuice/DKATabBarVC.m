//
//  DKATabBarVC.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/3/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "DKATabBarVC.h"
#import "DKADefines.h"
@interface DKATabBarVC ()

@end

@implementation DKATabBarVC

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
    
    //self.btnTab1.selected = YES;
    
    self.viewButton.frame = CGRectMake(0, self.view.frame.size.height-40, self.view.frame.size.width, 40);
    self.viewButton.backgroundColor = MAIN_ORANGE;
    
    self.btnTab1.tintColor = [UIColor whiteColor];
    self.btnTab2.tintColor = GRAY_TEXT_COLOR;
    self.btnTab3.tintColor = GRAY_TEXT_COLOR;
    
    [self.tabBar setHidden:YES];
    [self.view addSubview:self.viewButton];
    
	// Do any additional setup after loading the view.
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSLog(@"%i", btn.tag);
    self.btnTab1.selected = NO;
    self.btnTab2.selected = NO;
    self.btnTab3.selected = NO;
    self.btnTab1.tintColor = GRAY_TEXT_COLOR;
    self.btnTab2.tintColor = GRAY_TEXT_COLOR;
    self.btnTab3.tintColor = GRAY_TEXT_COLOR;

    
    //btn.selected = YES;
    btn.tintColor = [UIColor whiteColor];
    [self setSelectedIndex:btn.tag-1000];
 
    if(btn.tag-1000 == 0 || btn.tag-1000 == 1)
    {
        [((UINavigationController *)self.selectedViewController) popToRootViewControllerAnimated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
