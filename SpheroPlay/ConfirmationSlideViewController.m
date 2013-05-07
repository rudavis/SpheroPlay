//
//  ConfirmationSlideViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "ConfirmationSlideViewController.h"
#import "RobotKit/RobotKit.h"

@interface ConfirmationSlideViewController ()

@end

#define TOTAL_PACKET_COUNT 200
#define PACKET_COUNT_THRESHOLD 50
#define SHAKE_THRESHOLD 2

@implementation ConfirmationSlideViewController
@synthesize shakeLeftImage, shakeRightImage;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    robotDelay = 400.0;
    //Hide back button
    self.navigationItem.hidesBackButton = YES;
    
    [self successMacro];
    //[self failureMacro];
    
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
            
            //Stop this listening for streaming
            [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
            // Turn off data streaming
            [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:0
                                                           packetFrames:0
                                                             sensorMask:RKDataStreamingMaskOff
                                                            packetCount:0];
            // Unregister for async data packets
            [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self];
            // Restore stabilization (the control unit)
            [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
            // Turn off Back LED
            [RKBackLEDOutputCommand sendCommandWithBrightness:0.0f];
            // Close the connection
            [[RKRobotProvider sharedRobotProvider] closeRobotConnection];

            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1];
            shakeLeftImage.alpha = 1.0;
            shakeRightImage.alpha = 1.0;
            [UIView commitAnimations];
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //Pop to home
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) successMacro {

    //[RKSetDataStreamingCommand sendCommandStopStreaming];
    [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"success" ofType:@"sphero"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    //saves a temporary macro command thats includes the data packet
    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
    //Run temporary macro 255
    [RKRunMacroCommand sendCommandWithId:255];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];
}

- (void) failureMacro {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"fail" ofType:@"sphero"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    //saves a temporary macro command thats includes the data packet
    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
    //Run temporary macro 255
    [RKRunMacroCommand sendCommandWithId:255];
    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0];
}

- (IBAction)homeButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
