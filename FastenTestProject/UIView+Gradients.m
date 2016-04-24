//
//  UIView+Gradients.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "UIView+Gradients.h"
#import "HUFastenStylization.h"

@implementation UIView (Gradients)

- (NSDictionary <NSString*, UIColor*> *)produceGradientColorsFromColor:(UIColor*)baseColor WithColorDeviation:(CGFloat)maxColorDeviation{
    
    CGFloat redComp, greenComp, blueComp, alphaComp;
    [baseColor getRed:&redComp green:&greenComp blue:&blueComp alpha:&alphaComp];
    
    UIColor *topColor = [UIColor colorWithRed:((redComp <= (1.f - maxColorDeviation)) ? (redComp + maxColorDeviation) : 1.f) green:((greenComp <= (1.f - maxColorDeviation)) ? (greenComp + maxColorDeviation) : 1.f) blue:((blueComp <= (1.f - maxColorDeviation)) ? (blueComp + maxColorDeviation) : 1.f) alpha:alphaComp];
    UIColor *bottomColor = [UIColor colorWithRed:((redComp >= maxColorDeviation) ? (redComp - maxColorDeviation) : 0.f) green:((greenComp >= maxColorDeviation) ? (greenComp - maxColorDeviation) : 0.f) blue:((blueComp >= maxColorDeviation) ? (blueComp - maxColorDeviation) : 0.f) alpha:alphaComp];
    
    NSDictionary <NSString*, UIColor*> *dictionaryColors = @{@"topGradientColor" : topColor,  @"bottomGradientColor" : bottomColor};
    return dictionaryColors;
}

- (void)addGradientWithUpperColor:(UIColor*)topColor withLowerColor:(UIColor*)bottomColor{
    
    self.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setFrame:self.bounds];
    gradientLayer.startPoint = CGPointMake(0.5f, 0.f);
    gradientLayer.endPoint = CGPointMake(0.5f, 1.f);
    
    gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
    gradientLayer.cornerRadius = self.layer.cornerRadius;
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)addGradientWithBaseColor:(UIColor*)baseColor andColorDeviation:(CGFloat)colorDeviation{
    
    NSDictionary <NSString*, UIColor*> *dictionaryColors = [self produceGradientColorsFromColor:baseColor WithColorDeviation:colorDeviation];
    
    UIColor *topColor = dictionaryColors[@"topGradientColor"];
    UIColor *bottomColor = dictionaryColors[@"bottomGradientColor"];
    
    [self addGradientWithUpperColor:topColor withLowerColor:bottomColor];
}

@end
