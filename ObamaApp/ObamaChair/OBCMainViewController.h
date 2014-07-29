//
//  OBCMainViewController.h
//  ObamaChair
//
//  Created by ハルフダン ランプ on 2014/07/25.
//  Copyright (c) 2014年 ハルフダン ランプ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE/BLE.h"

@interface OBCMainViewController : UIViewController <BLEDelegate>
- (IBAction)btnConnectPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnConnect;
@property (strong, nonatomic) IBOutlet UIImageView *faceImageContainer;
@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) NSArray *color;

@property (atomic) float reading_left;
@property (atomic) float reading_right;
@property (atomic) float reading_back;

@end
