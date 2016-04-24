//
//  HURC3339DateFormatter.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HURFC3339DateFormatter : NSObject

@property (strong, nonatomic) NSDateFormatter *internalDateFormatter;
@property (copy, nonatomic) NSString *expirationString;

+ (instancetype)formatterForExpirationString:(NSString*)expirationString;
- (NSDate*)createExpirationDate;


@end
