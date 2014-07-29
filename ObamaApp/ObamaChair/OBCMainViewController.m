//
//  OBCMainViewController.m
//  ObamaChair
//
//  Created by ハルフダン ランプ on 2014/07/25.
//  Copyright (c) 2014年 ハルフダン ランプ. All rights reserved.
//

#import "OBCMainViewController.h"


@implementation OBCMainViewController
@synthesize ble;
//@synthesize btnConnect;

int timeout = 2;
float norm_sides = 0.2f;
float norm_back = 0.34f;
float sensitivity = 0.2f;
NSTimer *rssiTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    self.color = [[NSArray alloc] init];

    self.view.backgroundColor = [UIColor whiteColor];
    self.faceImageContainer.image = [UIImage imageNamed:@"FrontBama.png"];

    self.btnPresetOne.backgroundColor = [UIColor whiteColor];
    self.btnSensorStatus.backgroundColor = [UIColor whiteColor];
    
    self.ble = [[BLE alloc] init];
    [self.ble controlSetup];
    self.ble.delegate = self;
    self.preset_one_set = false;
    self.distance_preset_one = 0.0f;
    [self initAudioPlayer];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(obamaWasTapped)];
    [self.faceImageContainer addGestureRecognizer:singleTap];
    [self.faceImageContainer setMultipleTouchEnabled:YES];
    [self.faceImageContainer setUserInteractionEnabled:YES];
    // Do any additional setup after loading the view.
    

    
}

-(void)obamaWasTapped{
    NSLog(@"YOU TOUCHED OBAMAS FACE!");
    [self connectBLE];
    [self rotateFaceImageWithAtSpeed:1.0f fromAngle:0 toAngle:2*M_PI andRepeat:INFINITY];
//    [self rotateFaceImageWithAtSpeed: 5.0f]
//    [self rotateFaceImageWithAtSpeed:5.0f];//    self.btnConnect.backgroundColor = [UIColor redColor];
}


-(void) checkDistanceForPreset{
    if (self.distance_preset_one > sensitivity) {
        self.faceImageContainer.image = [UIImage imageNamed:@"cryface.png"];
        [self playAudio];
    } else{
        self.faceImageContainer.image = [UIImage imageNamed:@"ObamaCutout2.png"];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




-(void) connectBLE{
    if (self.ble.activePeripheral)
        if(self.ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[self.ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    
    if (self.ble.peripherals)
        self.ble.peripherals = nil;
//    [self.btnConnect setEnabled:false];
    [self.ble findBLEPeripherals:timeout];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
}


- (IBAction)btnPreset1Pressed:(id)sender {
    if (self.preset_one_set) {
        self.preset_one_set = false;
    } else{
        self.preset_one_set = true;
    }
//    self.btnLeftReading.backgroundColor = [UIColor colorWithRed:self.reading_left green:self.reading_right blue:self.reading_back alpha:1.0];


}

-(void) initAudioPlayer{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/cry1.wav", [[NSBundle mainBundle] resourcePath]];
    
    NSLog(@"%@",soundFilePath);
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self.audioPlayer setVolume:1.0];
}

- (void)playAudio {
//    [self playSound:@"cry1" :@"wav"];
//
    
    
    
//    [self.audioPlayer stop];
//    [self.audioPlayer setCurrentTime:0];
    [self.audioPlayer play];
//
//    
}

- (void)playSound :(NSString *)fName :(NSString *) ext{
    SystemSoundID audioEffect;
    NSString *path = [[NSBundle mainBundle] pathForResource : fName ofType :ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path]) {
        NSURL *pathURL = [NSURL fileURLWithPath: path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    else {
        NSLog(@"error, file not found: %@", path);
    }
}


-(void) readRSSITimer:(NSTimer *)timer
{
    [ble readRSSI];
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    [self.faceImageContainer.layer removeAllAnimations];
//    [self rotateFaceImageWithAtSpeed:100.0f];
    
//    [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
//    self.faceImageContainer.image = nil;

    [self.distanceTimer invalidate];
    self.lblGreetingButton.alpha = 1;
    self.lblGreetingTop.alpha = 1;
    self.faceImageContainer.image = [UIImage imageNamed:@"FrontBama.png"];

    [rssiTimer invalidate];
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
}
//-(void) readValue: (CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p



// When disconnected, this will be called
-(void) bleDidConnect
{
    self.faceImageContainer.image = [UIImage imageNamed:@"ObamaCutout2.png"];
    [self.faceImageContainer.layer removeAllAnimations];
//    [self rotateFaceImageWithAtSpeed:1 fromAngle:0 toAngle:-M_PI/2 andRepeat:1];
//    [self rotateFaceImageWithAtSpeed:1 fromAngle:-M_PI/2 toAngle:M_PI/2 andRepeat:1];
//    [self rotateFaceImageWithAtSpeed:1 fromAngle:M_PI/2 toAngle:0 andRepeat:1];
    NSLog(@"->Connected");
   self.distanceTimer = [NSTimer scheduledTimerWithTimeInterval:(float)0.1 target:self selector:@selector(checkDistanceForPreset) userInfo:nil repeats:YES];
//    self.faceImageContainer.image = [UIImage imageNamed:@"ObamaCutout2.png"];
    self.faceImageContainer.alpha = 1;
    
    self.lblGreetingButton.alpha = 0;
    self.lblGreetingTop.alpha = 0;
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:4];
    [ble write:data];
    
    // Schedule to read RSSI every 1 sec.
//    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];


}

-(float) calculateColorDistanceForLeft:(float)left andRight:(float)right andBack:(float)back andPreset:(UIButton *) presetButton{
    CGFloat* presetLRB = CGColorGetComponents(self.btnPresetOne.backgroundColor.CGColor);
    float distance = pow(presetLRB[0] - left, 2) + pow(presetLRB[1] - right, 2) + pow(presetLRB[2] - back, 2);
    return distance;
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    for (int i = 0; i < length; i+=4){
        if (data[i] == 0x0B)
        {
            self.reading_left = MAX((1.0f - data[i+1] / 255.0f) * (1.0f + norm_sides) - norm_sides, 0);
            self.reading_right = MAX((1.0f - data[i+2] / 255.0f) * (1.0f + norm_sides) - norm_sides, 0);
            self.reading_back = MAX((1.0f - data[i+3] / 255.0f) * (1.0f + norm_back) - norm_back, 0);
        }
    }
//    [self.btnPresetOne setFrame:CGRectMake(33, 36, 60, 60 * 1/self.reading_left)];

    UIColor *current_color = [UIColor colorWithRed:self.reading_left green:self.reading_right blue:self.reading_back alpha:1.0];
    self.btnSensorStatus.backgroundColor = current_color;
//    self.faceImageContainer.backgroundColor = current_color;
    
    if (!self.preset_one_set) {
        self.btnPresetOne.backgroundColor = current_color;
    }
    self.distance_preset_one = [self calculateColorDistanceForLeft:self.reading_left andRight:self.reading_right andBack:self.reading_back andPreset:self.btnPresetOne];

    
    NSLog(@"Distance %02f", self.distance_preset_one);

    
}

-(void) rotateFaceImageWithAtSpeed:(float)speed fromAngle:(float) startAngle toAngle:(float) endAngle andRepeat:(int) n_repeat{
    
    self.faceAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    self.faceAnimation.fromValue = [NSNumber numberWithFloat:startAngle];
    self.faceAnimation.toValue = [NSNumber numberWithFloat: endAngle];
    self.faceAnimation.duration = speed;
    self.faceAnimation.repeatCount = n_repeat;
    [self.faceImageContainer.layer addAnimation:self.faceAnimation forKey:@"SpinAnimation"];
    
//    [UIView animateWithDuration : 0.5
//                          delay : 0
//                        options : UIViewAnimationOptionBeginFromCurrentState
//                     animations : (void (^)(void)) ^{
//                         self.faceImageContainer.transform = CGAffineTransformMakeScale(scaling, scaling);
//                         self.faceImageContainer.transform = CGAffineTransformRotate(transform, degreesToRadians(-10));
//                     }
//                      completion:^(BOOL finished){
//                          self.faceImageContainer.transform = CGAffineTransformIdentity;
//                      }];
    
//    [UIView animateWithDuration : 0.5
//                          delay : 0
//                        options : UIViewAnimationOptionBeginFromCurrentState
//                     animations : (void (^)(void)) ^{
//                         self.faceImageContainer.transform = CGAffineTransformMakeScale(1/scaling, 1/scaling);
//                     }
//                      completion:^(BOOL finished){
//                          self.faceImageContainer.transform = CGAffineTransformIdentity;
//                      }];
}





-(void) connectionTimer:(NSTimer *)timer
{
//    [btnConnect setEnabled:true];
    
//    [btnConnect setTitle:@"" forState:UIControlStateNormal];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
//        [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    }
}



@end
