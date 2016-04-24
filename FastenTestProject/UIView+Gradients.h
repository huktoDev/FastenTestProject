//
//  UIView+Gradients.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Gradients)

- (void)addGradientWithUpperColor:(UIColor*)topColor withLowerColor:(UIColor*)bottomColor;
- (void)addGradientWithBaseColor:(UIColor*)baseColor andColorDeviation:(CGFloat)colorDeviation;

@end
