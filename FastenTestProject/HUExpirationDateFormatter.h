//
//  HUExpirationDateFormatter.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HUExpirationDateFormatter : NSObject

@property (strong, nonatomic) NSDateFormatter *internalDateFormatter;
@property (copy, nonatomic) NSDate *expirationDate;

+ (instancetype)formatterForExpirationDate:(NSDate*)expirationDate;
- (NSString*)createExpirationDateString;

@end
