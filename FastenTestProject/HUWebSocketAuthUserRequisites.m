//
//  HUWebSocketAuthUserRequisites.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUWebSocketAuthUserRequisites.h"

@implementation HUWebSocketAuthUserRequisites

+ (instancetype)userRequisitesWithEmail:(NSString*)email withPassword:(NSString*)password{
    HUWebSocketAuthUserRequisites *userRequisites = [[self class] new];
    
    userRequisites.email = email;
    userRequisites.password = password;
    
    return userRequisites;
}

@end
