//
//  HURC3339DateFormatter.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HURFC3339DateFormatter.h"

@implementation HURFC3339DateFormatter

+ (instancetype)formatterForExpirationString:(NSString*)expirationString{
    HURFC3339DateFormatter *dateFormatter = [HURFC3339DateFormatter new];
    
    dateFormatter.expirationString = expirationString;
    
    NSDateFormatter *rfc3339DateFormatter = [NSDateFormatter new];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    dateFormatter.internalDateFormatter = rfc3339DateFormatter;
    
    return dateFormatter;
}

- (NSDate*)createExpirationDate{
    
    NSDate *expirationDate = [self.internalDateFormatter dateFromString:self.expirationString];
    return expirationDate;
}

@end
