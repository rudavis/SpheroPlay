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

#define TOTAL_PACKET_COUNT 200
#define PACKET_COUNT_THRESHOLD 50
#define SHAKE_THRESHOLD 5

@implementation ForSlidingViewController
@synthesize totalAmountLabel, checkingAmounLabel, savingsAmountLabel, amountSlider;
@synthesize combinedAmount, initialCheckingAmount, initialSavingsAmount, newCheckingAmount, newSavingsAmount;
@synthesize tiltLeftArrow, tiltRightArrow, shakeLeftImage, shakeRightImage;


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
    initialCheckingAmount = 750.00;
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
    UIImage *minImage = [[UIImage imageNamed:@"slider_left.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    UIImage *thumbImage = [UIImage imageNamed:@"slider_indicator.png"];
    [amountSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [amountSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [amountSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    //Customize images
    //shakeLeftImage.hidden = YES;
    //shakeRightImage.hidden = YES;
    //tiltLeftArrow.hidden = YES;
    //tiltRightArrow.hidden = YES;
    
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

        destViewController.initialCheckingAmount = initialCheckingAmount;
        destViewController.initialSavingsAmount = initialSavingsAmount;
        destViewController.newCheckingAmount = newCheckingAmount;
        destViewController.newSavingsAmount = newSavingsAmount;
        
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
        [RKSetDataStreamingCommand sendCommandStopStreaming];
        // Start streaming sensor data
        ////First turn off stabilization so the drive mechanism does not move.
        [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOff];
        // Turn on the Back LED for reference
        [RKBackLEDOutputCommand sendCommandWithBrightness:1.0f];
        //Set color to Orange for fun
        [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.65 blue:0.0];
        
        [self sendSetDataStreamingCommand];
        
        ////Register for asynchronise data streaming packets
        [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleAsyncData:)];
    robotOnline = YES;
}

-(void)sendSetDataStreamingCommand {
    
    // Requesting the Accelerometer X, Y, and Z filtered (in Gs)
    //            the IMU Angles roll, pitch, and yaw (in degrees)
    //            the Quaternion data q0, q1, q2, and q3 (in 1/10000) of a Q
    RKDataStreamingMask mask = RKDataStreamingMaskAccelerometerFilteredAll | RKDataStreamingMaskIMUAnglesFilteredAll;

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
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1];
            shakeLeftImage.alpha = 1.0;
            shakeRightImage.alpha = 1.0;
            [UIView commitAnimations];
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSegueWithIdentifier:@"validateSlideSegue" sender:self];
            });
        }
        
        //Slide slider with Roll Data (Roll data: +/- 90 degrees)
        RKAttitudeData *attitudeData = sensorsData.attitudeData;
        float roll = attitudeData.roll;
        
        //Signifiant tilt
        if (roll > 15 || roll < -15) {
            if (roll > 15) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.1];
                tiltRightArrow.alpha = 1.0;
                [UIView commitAnimations];
            } else {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.1];
                tiltLeftArrow.alpha = 1.0;
                [UIView commitAnimations];

            }
            //I used 3 * ceilf(roll/10) to make the slider move faster the more you tilt
            //divide by 10, Round up to next int, times 3
            [amountSlider setValue:amountSlider.value + 3 * ceilf(roll/10) animated:YES];
            
            double savingsAmount = [amountSlider maximumValue] - [amountSlider value];
            checkingAmounLabel.text = [NSString stringWithFormat:@"Checking: %.0f", [amountSlider value]];
            savingsAmountLabel.text = [NSString stringWithFormat:@"Savings: %.0f", savingsAmount];
        }
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        tiltLeftArrow.alpha = 0.4;
        tiltRightArrow.alpha = 0.4;
        [UIView commitAnimations];
    }
}


@end
