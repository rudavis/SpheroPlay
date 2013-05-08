//
//  ArcadeModeViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 5/3/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "ArcadeModeViewController.h"
#import "RobotKit/RobotKit.h"

@implementation ArcadeModeViewController
@synthesize quarterImage,slotImage;
@synthesize creditsLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
    [RKBackLEDOutputCommand sendCommandWithBrightness:0.0f];
    [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    [[RKRobotProvider sharedRobotProvider] controlConnectedRobot];
    [RKRGBLEDOutputCommand sendCommandWithRed:.5 green:.5 blue:.5];
    
    creditsRemaining = 0.75;

    creditsLabel.text = [NSString stringWithFormat:@"%.2f", creditsRemaining];
    if (creditsRemaining <= 0) {
        quarterImage.hidden = YES;
        //TODO:
        //Add a message saying go add credits
    }

}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    //Move Quarter
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    //Drop quarter
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        //Bounds of coin slot
        //quarter x >= 170
        //quarter y <= 90
        if (recognizer.view.center.x >= 170.0 && recognizer.view.center.y <=90){
            //They dropped the quarter in the slot!!
            [self coinDroppedInSlot];
        }
    }
}

- (void) coinDroppedInSlot {
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];

//    NSString *file = [[NSBundle mainBundle] pathForResource:@"spin" ofType:@"sphero"];
//    NSData *data = [NSData dataWithContentsOfFile:file];
//    
//    //saves a temporary macro command thats includes the data packet
//    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
//    //Run temporary macro 255
//    [RKRunMacroCommand sendCommandWithId:255];
    
    //Deduct a quarter
    creditsRemaining = creditsRemaining - 0.25;
    creditsLabel.text = [NSString stringWithFormat:@"%.2f", creditsRemaining];
    if (creditsRemaining <= 0) {
        quarterImage.hidden = YES;
        //TODO:
        //Add a message saying go add credits
    }
    
    
    //Close connection for some reason...
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

    
    [self performSegueWithIdentifier:@"ArcadeDriveSegue" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PiggyBankModal"])
	{
		PiggyBankViewController *piggyBankViewController = segue.destinationViewController;
		piggyBankViewController.delegate = self;
	}
}



#pragma mark - PiggyBank Delegate
-(void) piggyBankViewControllerDidPressCancel:(PiggyBankViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) piggyBankViewController: (PiggyBankViewController *)controller DidPressDone:(float)credits{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    creditsLabel.text = [NSString stringWithFormat:@"%.2f", credits];
    creditsRemaining = credits;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
