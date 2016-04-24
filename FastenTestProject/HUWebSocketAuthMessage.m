//
//  HUWebSocketAuthMessage.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 13.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUWebSocketAuthMessage.h"

NSString* const AUTH_REQUEST_MESSAGE_TYPE = @"LOGIN_CUSTOMER";
NSString* const AUTH_SUCCESS_RESPONSE_MESSAGE_TYPE = @"CUSTOMER_API_TOKEN";
NSString* const AUTH_BAD_RESPONSE_MESSAGE_TYPE = @"CUSTOMER_ERROR";
NSString* const AUTH_VALIDATION_ERROR_MESSAGE_TYPE = @"CUSTOMER_VALIDATION_ERROR";

@implementation HUWebSocketAuthMessage

+ (NSArray <NSString*>*)predefinedTypes{
    
    return @[AUTH_REQUEST_MESSAGE_TYPE, AUTH_SUCCESS_RESPONSE_MESSAGE_TYPE, AUTH_BAD_RESPONSE_MESSAGE_TYPE, AUTH_VALIDATION_ERROR_MESSAGE_TYPE];
}

/// Если аутентификация была успешна - YES (сообщение с типом AUTH_SUCCESS_RESPONSE_MESSAGE_TYPE)
- (BOOL)isAuthSuccess{
    if([self.messageType isEqualToString:AUTH_SUCCESS_RESPONSE_MESSAGE_TYPE]){
        return YES;
    }else{
        return NO;
    }
}


@end

