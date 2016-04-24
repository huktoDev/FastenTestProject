//
//  HULeftTimeFormatter.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@interface HULeftTimeFormatter : NSObject

@property (copy, nonatomic) NSDate *expirationDate;

+ (instancetype)formatterForExpirationDate:(NSDate*)expirationDate;
- (NSString*)createLeftTimeString;

@end
