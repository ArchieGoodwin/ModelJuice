//
//  UILabel+Boldify.h
//  ModelJuice
//
//  Created by Nero Wolfe on 9/3/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Boldify)



- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;
@end
