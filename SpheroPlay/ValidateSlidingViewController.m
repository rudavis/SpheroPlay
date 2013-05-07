//
//  ValidateSlidingViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/17/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ValidateSlidingViewController.h"
#import "ConfirmationSlideViewController.h"
#import "RobotKit/RobotKit.h"

@interface ValidateSlidingViewController ()

@end

#define TOTAL_PACKET_COUNT 200
#define PACKET_COUNT_THRESHOLD 50
#define SHAKE_THRESHOLD 2

@implementation ValidateSlidingViewController
@synthesize combinedAmount, initialCheckingAmount, initialSavingsAmount, newCheckingAmount, newSavingsAmount, transferAmount, transferAmountLabel, fromAccountLabel,toAccountLabel, updatedSavingsAmountLabel,updatedCheckingAmountLabel;
@synthesize shakeRightImage, shakeLeftImage;

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

    
    if (self.newSavingsAmount > self.initialSavingsAmount) {
        //They transfered money into savings.
        
        self.transferAmount = self.newSavingsAmount - self.initialSavingsAmount;
        self.transferAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.transferAmount];
        self.fromAccountLabel.text = [NSString stringWithFormat:@"Checking"];
        [self.fromAccountLabel setTextColor:[UIColor redColor]];
        self.toAccountLabel.text = [NSString stringWithFormat:@"Savings"];
        [self.toAccountLabel setTextColor:[UIColor blueColor]];
                
    } else if (self.newSavingsAmount < self.initialSavingsAmount) {
        //They transfered into checking
        
        self.transferAmount = self.initialSavingsAmount - self.newSavingsAmount;
        self.transferAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.transferAmount];
        self.fromAccountLabel.text = [NSString stringWithFormat:@"Savings"];
        [self.fromAccountLabel setTextColor:[UIColor blueColor]];
        self.toAccountLabel.text = [NSString stringWithFormat:@"Checking"];
        [self.toAccountLabel setTextColor:[UIColor redColor]];
    } else if (self.newSavingsAmount == self.initialSavingsAmount) {
        //They didn't transfer anything
        self.transferAmountLabel.text = [NSString stringWithFormat:@"$0.00"];
        self.fromAccountLabel.text = [NSString stringWithFormat:@"Checking"];
        [self.fromAccountLabel setTextColor:[UIColor redColor]];
        self.toAccountLabel.text = [NSString stringWithFormat:@"Savings"];
        [self.toAccountLabel setTextColor:[UIColor blueColor]];
    }
    
    // Always set the new Savings & Checking amounts
    self.updatedSavingsAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.newSavingsAmount];
    self.updatedCheckingAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.newCheckingAmount];
    //We are assuming the Robot is online from sliding view controller
    [self handleRobotOnline];
    
}
- (void)handleRobotOnline {
    //We are assuming the Robot is still online from sliding view
    //Set up streaming on this controller
    [RKSetDataStreamingCommand sendCommandStopStreaming];
    [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOff];
    [RKBackLEDOutputCommand sendCommandWithBrightness:1.0f];
    [self sendSetDataStreamingCommand];
    [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleAsyncData:)];
}

-(void)sendSetDataStreamingCommand {
    //Just need Acceleration for Shake
    RKDataStreamingMask mask = RKDataStreamingMaskAccelerometerFilteredAll;
    
    //Same config as sliding view controller
    uint16_t divisor = 40;
    uint16_t packetFrames = 1;
    uint8_t count = 0;
    packetCount = 0;
    [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:divisor
                                                   packetFrames:packetFrames
                                                     sensorMask:mask
                                                    packetCount:count];
    
}

- (void)handleAsyncData:(RKDeviceAsyncData *)asyncData {
    if ([asyncData isKindOfClass:[RKDeviceSensorsAsyncData class]]) {
        
        // If we are getting close to packet limit, request more
        packetCount++;
        if( packetCount > (TOTAL_PACKET_COUNT-PACKET_COUNT_THRESHOLD)) {
            [self sendSetDataStreamingCommand];
        }
        
        // Received sensor data
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)asyncData;
        RKDeviceSensorsData *sensorsData = [sensorsAsyncData.dataFrames lastObject];
        
        //We use Accelerometer for SHAKE
        RKAccelerometerData *accelerometerData = sensorsData.accelerometerData;
        float x = accelerometerData.acceleration.x;
        float y = accelerometerData.acceleration.y;
        float z = accelerometerData.acceleration.z;
        //General Shake ~2 - 3 is good.
        if ( sqrt(pow(x,2) + pow(y,2) + pow(z,2)) > SHAKE_THRESHOLD) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1];
            shakeLeftImage.alpha = 1.0;
            shakeRightImage.alpha = 1.0;
            [UIView commitAnimations];
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSegueWithIdentifier:@"ConfirmationSegue" sender:self];
            });
        }
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ConfirmationSegue"]) {
//         ConfirmationSlideViewController *destViewController = segue.destinationViewController;
        
        //Stop this listening for streaming
        [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
        // Turn off data streaming
        [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:0
                                                       packetFrames:0
                                                         sensorMask:RKDataStreamingMaskOff
                                                        packetCount:0];
        // Unregister for async data packets
        [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
