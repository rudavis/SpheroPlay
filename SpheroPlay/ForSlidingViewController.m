//
//  ForSlidingViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/17/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "ForSlidingViewController.h"
#import "ValidateSlidingViewController.h"
#import "RobotKit/RobotKit.h"

#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)
#define TOTAL_PACKET_COUNT 200
#define PACKET_COUNT_THRESHOLD 50

@implementation ForSlidingViewController
@synthesize totalAmountLabel, checkingAmounLabel, savingsAmountLabel, amountSlider;
@synthesize combinedAmount, initialCheckingAmount, initialSavingsAmount, newCheckingAmount, newSavingsAmount;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Set initial Amounts
    combinedAmount = 1000.0;
    initialCheckingAmount = 550.00;
    initialSavingsAmount = combinedAmount - initialCheckingAmount;
    
    //Set label values from initial amounts
    totalAmountLabel.text = [NSString stringWithFormat:@"Total:  %.0f", combinedAmount];
    checkingAmounLabel.text = [NSString stringWithFormat:@"Checking: %.0f", initialCheckingAmount];
    savingsAmountLabel.text = [NSString stringWithFormat:@"Savings: %.0f", initialSavingsAmount];
    
    //Set the slider values
    amountSlider.minimumValue = 0.0;
    amountSlider.maximumValue = combinedAmount;
    amountSlider.value = initialCheckingAmount;
    
    //Customize Slider
    UIImage *minImage = [[UIImage imageNamed:@"red_slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"blue_slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    UIImage *thumbImage = [UIImage imageNamed:@"dollar_sign.gif"];
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    
    
    /*Register for application lifecycle notifications so we known when to connect and disconnect from the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    /*Only start the blinking loop when the view loads*/
    robotOnline = NO;

    [self setupRobotConnection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    double savingsAmount = [sender maximumValue] - [sender value];
    
    checkingAmounLabel.text = [NSString stringWithFormat:@"Checking: %.0f", [sender value]];
    savingsAmountLabel.text = [NSString stringWithFormat:@"Savings: %.0f", savingsAmount];
}

- (IBAction)continueButtonPressed:(id)sender {
    newCheckingAmount = amountSlider.value;
    newSavingsAmount = combinedAmount - newCheckingAmount;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"validateSlideSegue"]) {

        newCheckingAmount = amountSlider.value;
        newSavingsAmount = combinedAmount - newCheckingAmount;
        
        ValidateSlidingViewController *destViewController = segue.destinationViewController;

        destViewController.combinedAmount = combinedAmount;
        destViewController.initialCheckingAmount = initialCheckingAmount;
        destViewController.initialSavingsAmount = initialSavingsAmount;
        destViewController.newCheckingAmount = newCheckingAmount;
        destViewController.newSavingsAmount = newSavingsAmount;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)appWillResignActive:(NSNotification*)notification {
    /*When the application is entering the background we need to close the connection to the robot*/
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
    
    robotOnline = NO;
}

-(void)appDidBecomeActive:(NSNotification*)notification {
    /*When the application becomes active after entering the background we try to connect to the robot*/
    [self setupRobotConnection];
}

-(void)setupRobotConnection {
    /*Try to connect to the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
}

- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline) {
        
        [RKSetDataStreamingCommand sendCommandStopStreaming];
        // Start streaming sensor data
        ////First turn off stabilization so the drive mechanism does not move.
        [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOff];
        // Turn on the Back LED for reference
        [RKBackLEDOutputCommand sendCommandWithBrightness:1.0f];
        
        [self sendSetDataStreamingCommand];
        
        ////Register for asynchronise data streaming packets
        [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleAsyncData:)];
    }
    robotOnline = YES;
}

-(void)sendSetDataStreamingCommand {
    
    // Requesting the Accelerometer X, Y, and Z filtered (in Gs)
    //            the IMU Angles roll, pitch, and yaw (in degrees)
    //            the Quaternion data q0, q1, q2, and q3 (in 1/10000) of a Q
    //RKDataStreamingMask mask =  RKDataStreamingMaskAccelerometerFilteredAll |
    //RKDataStreamingMaskIMUAnglesFilteredAll   |
    //RKDataStreamingMaskQuaternionAll;
    
    //I think I just need Roll from the Angles stream
    RKDataStreamingMask mask = RKDataStreamingMaskAccelerometerFilteredAll;
    //RKDataStreamingMaskIMUAnglesFilteredAll | RKDataStreamingMaskGyroXFiltered | RKDataStreamingMaskGyroYFiltered;
    
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
        
        // Received sensor data, so display it to the user.
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)asyncData;
        RKDeviceSensorsData *sensorsData = [sensorsAsyncData.dataFrames lastObject];
        RKAccelerometerData *accelerometerData = sensorsData.accelerometerData;

        float x = accelerometerData.acceleration.x;
        float xOffset = x * 25.0;
        NSLog([NSString stringWithFormat:@"%1.2f", xOffset]);
        

        if (xOffset > 4 || xOffset < -4) {
            [amountSlider setValue:amountSlider.value + xOffset animated:YES];
        
            double savingsAmount = [amountSlider maximumValue] - [amountSlider value];
            checkingAmounLabel.text = [NSString stringWithFormat:@"Checking: %.0f", [amountSlider value]];
            savingsAmountLabel.text = [NSString stringWithFormat:@"Savings: %.0f", savingsAmount];
        }
    }
}


@end
