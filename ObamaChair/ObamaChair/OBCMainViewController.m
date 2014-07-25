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
    self.ble = [[BLE alloc] init];
    [self.ble controlSetup];
    self.ble.delegate = self;
    self.view.backgroundColor = [UIColor blackColor];
    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(obamaWasTapped)];
//    [self.faceImageContainer addGestureRecognizer:singleTap];
//    [self.faceImageContainer setMultipleTouchEnabled:YES];
//    [self.faceImageContainer setUserInteractionEnabled:YES];
//   [self.faceImageContainer add];
    // Do any additional setup after loading the view.
}

//-(void)obamaWasTapped{
//    NSLog(@"YOU TOUCHED OBAMAS FACE!");
//}



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
//            [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    
    if (self.ble.peripherals)
        self.ble.peripherals = nil;
    [self.btnConnect setEnabled:false];
//    btnConnect setEnabled:false];
    [self.ble findBLEPeripherals:timeout];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}




////
//-(void) bleDidConnect
//{
//    NSLog(@"->Connected");
//    
//    
//    //[colorthing backgroundColor: @"[UIColor redColor]"];
//    
//    self.faceImageContainer.image = [UIImage imageNamed:@"ObamaCutout2.png"];
//    self.view.backgroundColor = [UIColor blueColor];
//    
//    
//    
//    // send reset
//    UInt8 buf[] = {0x04, 0x00, 0x00, 0x00};
//    NSData *data = [[NSData alloc] initWithBytes:buf length:4];
//    [ble write:data];
//    
//    // Schedule to read RSSI every 1 sec.
//    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
//   
//}

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
    
    
    //[colorthing backgroundColor: @"[UIColor redColor]"];
    
    self.faceImageContainer.image = [UIImage imageNamed:@"ObamaCutout2.png"];
    
    
    
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
    //    NSLog(@"Length: %d", length);
    UInt16 Value;
    UInt16 reading_left, reading_right, reading_back;
    for (int i = 0; i < length; i+=4)
    {
//        NSLog(@"0x%02X, 0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2], data[i+3]);
        
        if (data[i] == 0x0B)
        {
            reading_left = data[i+1];
            reading_right = data[i+2];
            reading_back = data[i+3];
            Value = data[i+2] | data[i+1] << 8;
            
            
        }
    }
    float red = reading_left / 255.0f;
    float blue = reading_right / 255.0f;
    float green = reading_back / 255.0f;
    NSLog(@"red: 0x%02f, green: 0x%02f, blue: 0x%02f", red, green, blue);
    //    NSLog(@"%0.0f", red);
    
//    [UIView animateWithDuration : 0.5
//                          delay : 0
//                        options : UIViewAnimationOptionBeginFromCurrentState
//                     animations : (void (^)(void)) ^{
//                         self.faceImageContainer.transform = CGAffineTransformMakeScale(1.2, 1.2);
//                     }
//                     completion:^(BOOL finished){
//                         self.faceImageContainer.transform = CGAffineTransformIdentity;
//                     }];
    
    self.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
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
