//
//  HUInfoViewController.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUInfoViewController.h"
#import "HULeftTimeFormatter.h"
#import "HUExpirationDateFormatter.h"

@implementation HUInfoViewController

@synthesize activeSessionInfo;

- (void)viewDidLoad{
    
    if(self.activeSessionInfo){
        
        NSDate *expirationDate = [self.activeSessionInfo expirationDate];
        HULeftTimeFormatter *leftTimeFormatter = [HULeftTimeFormatter formatterForExpirationDate:expirationDate];
        HUExpirationDateFormatter *expirationDateFormatter = [HUExpirationDateFormatter formatterForExpirationDate:expirationDate];
        
        NSString *leftTimeString = [leftTimeFormatter createLeftTimeString];
        self.leftTimeLabel.text = leftTimeString;
        
        NSString *descriptionExpiredDate = [expirationDateFormatter createExpirationDateString];
        self.expirationDateLabel.text = descriptionExpiredDate;
        
        NSString *userTokenString = [NSString stringWithFormat:@"User Token :\n%@", self.activeSessionInfo.apiToken];
        self.tokenLabel.text = userTokenString;
    }
}

@end
