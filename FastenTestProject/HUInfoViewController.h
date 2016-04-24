//
//  HUInfoViewController.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUWebSocketMessages.h"
#import "HUActiveSessionInfoProtocol.h"

@interface HUInfoViewController : UIViewController <HUActiveSessionInfoProtocol>

@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;

@end
