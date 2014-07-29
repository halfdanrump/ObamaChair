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
@synthesize btnConnect;

int timeout = 2;
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
    Float32 buf[] = {0.0f, 0.0f, 0.0f};
    self.color = [[NSArray alloc] init];
    self.ble = [[BLE alloc] init];
    [self.ble controlSetup];
    self.ble.delegate = self;
    self.view.backgroundColor = [UIColor blackColor];
    self.faceImageContainer.image = [UIImage imageNamed:@"ObamaCutout2.png"];
    self.faceImageContainer.alpha = 0;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(obamaWasTapped)];
    [self.faceImageContainer addGestureRecognizer:singleTap];
    [self.faceImageContainer setMultipleTouchEnabled:YES];
    [self.faceImageContainer setUserInteractionEnabled:YES];
    // Do any additional setup after loading the view.
}

-(void)obamaWasTapped{
    NSLog(@"YOU TOUCHED OBAMAS FACE!");
    [self scaleFaceImage:0];
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

- (IBAction)btnConnectPressed:(id)sender {
    
    
    if (self.ble.activePeripheral)
        if(self.ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[self.ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    
    if (self.ble.peripherals)
        self.ble.peripherals = nil;
    [self.btnConnect setEnabled:false];
    [self.ble findBLEPeripherals:timeout];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}



-(void) readRSSITimer:(NSTimer *)timer
{
    [ble readRSSI];
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    self.faceImageContainer.image = nil;
    
    
    [rssiTimer invalidate];
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
}


// When disconnected, this will be called
-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    


    self.faceImageContainer.alpha = 0.5;
//    [self fadeInObama];
//    [UIView animateWithDuration:5.0 animations:^{
//        self.faceImageContainer.alpha = 0.5;
//    }];
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:4];
    [ble write:data];
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
    
    UInt8 bufm[3] = {0xA0, 0x01, 0x00};
    
    NSData *datam = [[NSData alloc] initWithBytes:bufm length:3];
    [ble write:datam];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    for (int i = 0; i < length; i+=4){
        if (data[i] == 0x0B)
        {
            self.reading_left = 1.0f - data[i+1] / 255.0f;
            self.reading_right = 1.0f - data[i+2] / 255.0f;
            self.reading_back = 1.0f - data[i+3] / 255.0f;
        }
    }
//    NSLog(@"red: %02f, green: %02f, blue: %02f", red, green, blue);
//    scaling = 0.5 + red * green * blue;
    
//    [NSTimer scheduledTimerWithTimeInterval:(float)0.51 target:self selector:@selector(scaleFaceImage:) userInfo:nil repeats:NO];
    
    self.view.backgroundColor = [UIColor colorWithRed:self.reading_left green:self.reading_right blue:self.reading_back alpha:1.0];
    
}

-(void) scaleFaceImage:(float) scaling{
    [UIView animateWithDuration : 0.5
                          delay : 0
                        options : UIViewAnimationOptionBeginFromCurrentState
                     animations : (void (^)(void)) ^{
                         self.faceImageContainer.transform = CGAffineTransformMakeScale(scaling, scaling);
                     }
                      completion:^(BOOL finished){
                          self.faceImageContainer.transform = CGAffineTransformIdentity;
                      }];
    
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
    [btnConnect setEnabled:true];
    [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    }
}



@end
