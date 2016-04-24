//
//  HUActiveSessionInfoProtocol.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#ifndef HUActiveSessionInfoProtocol_h
#define HUActiveSessionInfoProtocol_h

@protocol HUActiveSessionInfoProtocol <NSObject>

@required
@property (strong, nonatomic) HUWebSocketAuthDataSuccessResponse *activeSessionInfo;

@end

#endif
