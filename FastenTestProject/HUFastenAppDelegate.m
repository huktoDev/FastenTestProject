//
//  AppDelegate.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 10.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUFastenAppDelegate.h"
#import "HUWebSocketClient.h"
#import "HUWebSocketAuthService.h"

@interface HUFastenAppDelegate ()

@end

@implementation HUFastenAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    HUWebSocketClient *webSocketClient = [HUWebSocketClient sharedClient];
    HUWebSocketAuthService *authService = [HUWebSocketAuthService sharedService];
    
    [webSocketClient configWebSocket];
    [authService configAuthService];

    return YES;
}

@end
