//
//  DKAScheduleVC.h
//  ModelJuice
//
//  Created by Nero Wolfe on 8/30/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKAScheduleVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@end
