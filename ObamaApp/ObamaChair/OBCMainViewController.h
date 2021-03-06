//
//  OBCMainViewController.h
//  ObamaChair
//
//  Created by ハルフダン ランプ on 2014/07/25.
//  Copyright (c) 2014年 ハルフダン ランプ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE/BLE.h"
#import <AVFoundation/AVFoundation.h>


@interface OBCMainViewController : UIViewController <BLEDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *faceImageContainer;
@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) NSArray *color;

@property (atomic) float reading_left;
@property (atomic) float reading_right;
@property (atomic) float reading_back;

@property (atomic) Boolean preset_one_set;
@property (atomic) float distance_preset_one;
//@property (atomic) Boolean preset_one_set;
//@property (atomic) Boolean preset_one_set;

@property (strong, nonatomic) IBOutlet UIButton *btnPresetOne;
@property (strong, nonatomic) IBOutlet UIButton *btnSensorStatus;
@property (strong, nonatomic) IBOutlet UILabel *lblGreetingTop;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet UILabel *lblGreetingButton;
@property (strong, nonatomic) NSTimer *distanceTimer;

@property (strong, nonatomic) CABasicAnimation* faceAnimation;
@end
