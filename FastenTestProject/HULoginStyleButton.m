//
//  HULoginStyleButton.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HULoginStyleButton.h"
#import "HUFastenStylization.h"
#import "BLMultiColorLoader.h"

@implementation HULoginStyleButton{
    
    __weak id actTarget;
    SEL actSelector;
    
    BLMultiColorLoader *multiColorLoader;
}

#pragma mark - Initialization & Config

- (instancetype)init{
    if(self = [super init]){
        [self configStyle];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self configStyle];
    }
    return self;
}

- (void)awakeFromNib{
    [super  awakeFromNib];
    [self configStyle];
}

- (void)configStyle{
    
    self.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [self setTitle:@"Login" forState:UIControlStateNormal];
    
    UIEdgeInsets loginTitleEdgeInsets = UIEdgeInsetsMake(0.f, 34.f, 0.f, 34.f);
    [self setContentEdgeInsets:loginTitleEdgeInsets];
    
    self.backgroundColor = [HUFastenStylization loginButtonColor];
    [self setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.6f] forState:UIControlStateNormal];
    
    [self addTarget:self action:@selector(loginButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(loginButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(loginButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(loginButtonTouchUpOutside:) forControlEvents:UIControlEventTouchCancel];
}

#pragma mark - Button Action

- (void)setTarget:(id)actionTarget actionSelector:(SEL)actionSelector{
    
    actTarget = actionTarget;
    actSelector = actionSelector;
}

#pragma mark - Events Handling

- (IBAction)loginButtonTouchDown:(UIButton *)loginButton {
    
    UIColor *loginBackColor = [HUFastenStylization loginButtonColor];
    [UIView animateWithDuration:0.2f animations:^{
        loginButton.backgroundColor = [loginBackColor colorWithAlphaComponent:0.5f];
    }];
}


- (IBAction)loginButtonTouchUpOutside:(UIButton *)loginButton {
    
    UIColor *loginBackColor = [HUFastenStylization loginButtonColor];
    [UIView animateWithDuration:0.2f animations:^{
        loginButton.backgroundColor = loginBackColor;
    }];
}


- (IBAction)loginButtonTouchUpInside:(UIButton *)loginButton {
    
    UIColor *loginBackColor = [HUFastenStylization loginButtonColor];
    [UIView animateWithDuration:0.2f animations:^{
        loginButton.backgroundColor = loginBackColor;
    }];
    
    if(actTarget && [actTarget respondsToSelector:actSelector]){
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        [actTarget performSelector:actSelector withObject:nil];
#pragma clang diagnostic pop
    }
}

#pragma mark - Login Indicator

- (void)showLoginIndicator{
    
    multiColorLoader = [[BLMultiColorLoader alloc] initWithFrame:CGRectMake(0.f, 0.f, 32.f, 32.f)];
    multiColorLoader.center = CGPointMake(CGRectGetWidth(self.frame) / 2.f, CGRectGetHeight(self.frame) / 2.f);
    [self addSubview:multiColorLoader];
    
    multiColorLoader.backgroundColor = [UIColor clearColor];
    
    multiColorLoader.lineWidth = 4.0;
    
    UIColor *firstColor = [[UIColor redColor] colorWithAlphaComponent:0.6f];
    UIColor *secondColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.6f];
    UIColor *thirdColor = [[UIColor yellowColor] colorWithAlphaComponent:0.6f];
    
    multiColorLoader.colorArray = @[firstColor, secondColor, thirdColor];
    [multiColorLoader startAnimation];
}

- (void)hideLoginIndicator{
    
    [multiColorLoader stopAnimation];
    [multiColorLoader removeFromSuperview];
    multiColorLoader = nil;
}


@end
