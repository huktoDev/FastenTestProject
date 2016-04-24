//
//  HUFastenStylization.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUFastenStylization.h"

@implementation HUFastenStylization

+ (UIColor*)successLoginColor{
    return [UIColor colorWithRed:(0.f/255.f) green:(100.f/255.f) blue:(0.f/255.f) alpha:1.f];
}

+ (UIColor*)failureLoginColor{
    return [UIColor redColor];
}

+ (UIColor*)loginButtonColor{
    
    return [UIColor colorWithRed:(104.f/255.f) green:(120.f/255.f) blue:(252.f/255.f) alpha:0.8f];
}

+ (UIColor*)loginScreenColor{
    
    return [UIColor colorWithRed:(161.f/255.f) green:1.f blue:(40.f/255.f) alpha:1.f];
}

@end
