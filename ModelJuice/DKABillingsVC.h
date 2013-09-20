//
//  DKABillingsVC.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/19/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKABillingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnFlag;
@property (strong, nonatomic) IBOutlet UIView *container;

@end
