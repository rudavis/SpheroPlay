//
//  PiggyBankViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 5/2/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "PiggyBankViewController.h"
#import "RobotKit/RobotKit.h"
#import "RobotUIKit/RobotUIKit.h"

#import <AVFoundation/AVFoundation.h>

#define TOTAL_PACKET_COUNT 200
#define PACKET_COUNT_THRESHOLD 50
#define SHAKE_THRESHOLD 2

@implementation PiggyBankViewController
@synthesize delegate;
@synthesize creditsLabel, numberOfShakesLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    packetCount = 0;
    numberOfShakes = 0;
    credits = 0.0;
    
    [RKSetDataStreamingCommand sendCommandStopStreaming];
    // Start streaming sensor data
    ////First turn off stabilization so the drive mechanism does not move.
    [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOff];
    // Turn off the Back LED for reference
    [RKBackLEDOutputCommand sendCommandWithBrightness:0.0f];
    //Set color to Pink
    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.64];
    
    [self sendSetDataStreamingCommand];
    
    ////Register for asynchronise data streaming packets
    [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleAsyncData:)];
}

-(void)sendSetDataStreamingCommand {
    
    // Requesting the Accelerometer X, Y, and Z filtered (in Gs)
    //            the IMU Angles roll, pitch, and yaw (in degrees)
    //            the Quaternion data q0, q1, q2, and q3 (in 1/10000) of a Q
    RKDataStreamingMask mask = RKDataStreamingMaskAccelerometerFilteredAll;
    
    // Sphero samples this data at 400 Hz.  The divisor sets the sample
    // rate you want it to store frames of data.  In this case 400Hz/40 = 10Hz
    uint16_t divisor = 40;
    
    // Packet frames is the number of frames Sphero will store before it sends
    // an async data packet to the iOS device
    uint16_t packetFrames = 1;
    
    // Count is the number of async data packets Sphero will send you before
    // it stops.  Set a count of 0 for infinite data streaming.
    uint8_t count = 0;
    
    packetCount = 0;
    
    // Send command to Sphero
    [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:divisor
                                                   packetFrames:packetFrames
                                                     sensorMask:mask
                                                    packetCount:count];
    
}

- (void)handleAsyncData:(RKDeviceAsyncData *)asyncData
{
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
        /*
         If you don't care on which axis it is shaken, then normalize the axis' by getting a
         square of the sum of their squares: sqrt(x^2 + y^2 + z^2) > 2000.
         This will give you a magnitude of the acceleration vector. It's a good value for
         "general acceleration-ness", and it's great for detecting shaking.
         */
        //General Shake ~2 - 3 is good.
        if ( sqrt(pow(x,2) + pow(y,2) + pow(z,2)) > SHAKE_THRESHOLD) {
            [self playSound];
            numberOfShakes++;
            numberOfShakesLabel.text = [NSString stringWithFormat:@"%i", numberOfShakes];
            credits = numberOfShakes * 0.25;
            creditsLabel.text = [NSString stringWithFormat:@"%.2f", credits];
        }
    }
}

- (void) playSound {
    SystemSoundID sounds[10];
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"coins" ofType:@"mp3"];
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundURL, &sounds[0]);
    AudioServicesPlaySystemSound(sounds[0]);
}


-(IBAction)cancel:(id)sender {
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
    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:1.0 blue:1.0];

    [self.delegate piggyBankViewControllerDidPressCancel:self];
}
- (IBAction)done:(id)sender {
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
    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:1.0 blue:1.0];

    [self.delegate piggyBankViewController:self DidPressDone:credits];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
