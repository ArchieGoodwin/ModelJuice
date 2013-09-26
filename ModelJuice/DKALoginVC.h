//
//  DKALoginVC.h
//  ModelJuice
//
//  Created by Nero Wolfe on 8/29/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKALoginVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *pwd;

- (IBAction)registerMe:(id)sender;
@end
