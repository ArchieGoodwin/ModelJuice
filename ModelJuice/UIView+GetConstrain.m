//
//  UIView+GetConstrain.m
//  ModelJuice
//
//  Created by Nero Wolfe on 9/24/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "UIView+GetConstrain.h"

@implementation UIView (GetConstrain)

- (NSArray *)constaintsForAttribute:(NSLayoutAttribute)attribute {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d", attribute];
    NSArray *filteredArray = [[self constraints] filteredArrayUsingPredicate:predicate];
    
    return filteredArray;
}

- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute {
    NSArray *constraints = [self constaintsForAttribute:attribute];
    
    if (constraints.count) {
        return constraints[0];
    }
    
    return nil;
}

@end
