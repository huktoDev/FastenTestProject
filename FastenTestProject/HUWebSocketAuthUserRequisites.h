//
//  HUWebSocketAuthUserRequisites.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HUWebSocketAuthUserRequisites : NSObject

@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *password;

+ (instancetype)userRequisitesWithEmail:(NSString*)email withPassword:(NSString*)password;

@end
