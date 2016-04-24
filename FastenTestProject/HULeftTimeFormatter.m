//
//  HULeftTimeFormatter.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HULeftTimeFormatter.h"

@implementation HULeftTimeFormatter

+ (instancetype)formatterForExpirationDate:(NSDate*)expirationDate{
    
    HULeftTimeFormatter *timeFormatter = [HULeftTimeFormatter new];
    timeFormatter.expirationDate = expirationDate;
    
    return timeFormatter;
}

- (NSString*)createLeftTimeString{
    
    NSString *leftTimeString = nil;
    NSDate *currentDate = [NSDate date];
    
    CGFloat intervalBetweenDates = [self.expirationDate timeIntervalSinceDate:currentDate];
    
    const NSUInteger SECONDS_COUNT_IN_MINUTE = 60;
    const NSUInteger MINUTES_COUNT_IN_HOUR = 60;
    const NSUInteger HOURS_COUNT_IN_DAY = 24;
    
    const NSUInteger DAY_SECONDS_COUNT = SECONDS_COUNT_IN_MINUTE * MINUTES_COUNT_IN_HOUR * HOURS_COUNT_IN_DAY;
    const NSUInteger HOUR_SECONDS_COUNT = SECONDS_COUNT_IN_MINUTE * MINUTES_COUNT_IN_HOUR;
    
    NSUInteger countDaysLeft = ((NSUInteger)intervalBetweenDates) / DAY_SECONDS_COUNT;
    if(countDaysLeft > 0){
        leftTimeString = [NSString stringWithFormat:@"Left %lu days", (unsigned long)countDaysLeft];
        return leftTimeString;
    }
    
    NSUInteger countHoursLeft = ((NSUInteger)intervalBetweenDates) / HOUR_SECONDS_COUNT;
    if(countHoursLeft > 0){
        leftTimeString = [NSString stringWithFormat:@"Left %lu hours", (unsigned long)countHoursLeft];
        return leftTimeString;
    }
    
    NSUInteger countMinutesLeft = ((NSUInteger)intervalBetweenDates) / SECONDS_COUNT_IN_MINUTE;
    if(countMinutesLeft > 0){
        leftTimeString = [NSString stringWithFormat:@"Left %lu minutes", (unsigned long)countMinutesLeft];
        return leftTimeString;
    }
    
    NSUInteger countSecondsLeft = ((NSUInteger)intervalBetweenDates);
    if(countSecondsLeft > 0){
        leftTimeString = [NSString stringWithFormat:@"Left %lu seconds", (unsigned long)countSecondsLeft];
        return leftTimeString;
    }
    
    leftTimeString = @"Time Left !!!";
    return leftTimeString;
}


@end
