//
//  HUExpirationDateFormatter.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUExpirationDateFormatter.h"

@implementation HUExpirationDateFormatter

+ (instancetype)formatterForExpirationDate:(NSDate*)expirationDate{
    HUExpirationDateFormatter *dateFormatter = [HUExpirationDateFormatter new];
    
    dateFormatter.expirationDate = expirationDate;
    
    NSDateFormatter *descriptionDateFormatter = [NSDateFormatter new];
    [descriptionDateFormatter setDateFormat:@"HH':'mm':'ss' 'dd'.'MM'.'YYYY"];
    [descriptionDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
    dateFormatter.internalDateFormatter = descriptionDateFormatter;
    return dateFormatter;
}

- (NSString*)createExpirationDateString{
    
    NSString *descriptionExpiredDate = [self.internalDateFormatter stringFromDate:self.expirationDate];
    descriptionExpiredDate = [NSString stringWithFormat:@"Expired Date : %@", descriptionExpiredDate];
    
    return descriptionExpiredDate;
}

@end
