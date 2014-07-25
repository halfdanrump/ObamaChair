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

    // Do any additional setup after loading the view.
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

-(void) connectionTimer:(NSTimer *)timer
{
    [self.btnConnect setEnabled:true];
    [self.btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    if (self.ble.peripherals.count > 0)
    {
        [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    }
}


//
-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    
    //[colorthing backgroundColor: @"[UIColor redColor]"];
    
    self.faceImageContainer.image = [UIImage imageNamed:@"ObamaCutout2.png"];
    self.view.backgroundColor = [UIColor blueColor];
    
    
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:4];
    [ble write:data];
    
    // Schedule to read RSSI every 1 sec.
//    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
    
    UInt8 bufm[3] = {0xA0, 0x01, 0x00};
    
    NSData *datam = [[NSData alloc] initWithBytes:bufm length:3];
    [ble write:datam];
}



@end
