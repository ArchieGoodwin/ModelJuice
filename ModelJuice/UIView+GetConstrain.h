//
//  UIView+GetConstrain.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/24/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (GetConstrain)
- (NSArray *)constaintsForAttribute:(NSLayoutAttribute)attribute;
- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute;
@end
