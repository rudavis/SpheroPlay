//
//  ForFunViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "ForFunViewController.h"
#import "RobotKit/RobotKit.h"
#import "RobotUIKit/RobotUIKit.h"
#import "PiggyBankViewController.h"


@implementation ForFunViewController
@synthesize connectionLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    robotOnline = NO;
    noSpheroViewShowing = NO;
    robotDelay = 400.0;

    ///  Connet to Sphero
    [self setupRobotConnection];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;

}

#pragma mark- Sphero Connections

- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    connectionLabel.text = @"CONNECTED";
    
    if(!robotOnline) {
        robotOnline = YES;
    }
    // Hide No Sphero Connected View
    if( noSpheroViewShowing ) {
        [noSpheroView dismissModalLayerViewControllerAnimated:YES];
        noSpheroViewShowing = NO;
    }
    robotOnline = YES;
}

-(void)setupRobotConnection {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGainControl:) name:RKRobotDidGainControlNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOffline) name:RKDeviceConnectionOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOffline) name:RKRobotDidLossControlNotification object:nil];
    
    //Attempt to control the connected robot so we get the notification if one is connected
    robotInitialized = NO;
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        robotInitialized = YES;
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
    else {
        robotOnline = NO;
        connectionLabel.text = @"CONNECTING";
        // Give the device a second to connect
        [self performSelector:@selector(showNoSpheroConnectedView) withObject:nil afterDelay:1.0];
    }
    robotInitialized = YES;
}

-(void)handleDidGainControl:(NSNotification*)notification {\
    NSLog(@"didGainControlNotification");
    if(!robotInitialized) return;
    [[RKRobotProvider sharedRobotProvider] openRobotConnection];
}

- (void)handleRobotOffline {
    if(robotOnline) {
        robotOnline = NO;
        //Put code to update UI for offline here
        connectionLabel.text = @"DISCONNECTED";
        [self showNoSpheroConnectedView];
    }
}

-(void)showNoSpheroConnectedView {
    if( robotOnline ) return;

    //Don't know why this doesn't show in Portriate mode.
/*
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    NSBundle* ruiBundle = [NSBundle bundleWithPath:ruirespath];
    
    NSString* nibName;
    // Change if your app is portrait
    nibName = @"RUINoSpheroConnectedViewController_Portrait";
    //nibName = @"RUINoSpheroConnectedViewController_Landscape";
    
    noSpheroView = [[RUINoSpheroConnectedViewController alloc]
                    initWithNibName:nibName
                    bundle:ruiBundle];
    [self presentModalLayerViewController:noSpheroView animated:YES];
    noSpheroViewShowing = YES;
*/
}

- (IBAction)colorButtonPressed:(id)sender {
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    RUIColorPickerViewController *cpc = [[RUIColorPickerViewController alloc] initWithNibName:@"RUIColorPickerViewController" bundle:[NSBundle bundleWithPath:ruirespath]];
    cpc.delegate = self;
    cpc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [cpc layoutPortrait];
    [cpc setRed:1.0 green:1.0 blue:1.0];
    
    [self presentViewController:cpc animated:YES completion:nil];
}

- (IBAction)sleepButtonPressed:(id)sender {
    //RobotUIKit resources like images and nib files stored in an external bundle and the path must be specified
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    NSBundle* ruiBundle = [NSBundle bundleWithPath:ruirespath];
    
    //Present the slide to sleep view controller
    RUISlideToSleepViewController *sleep = [[RUISlideToSleepViewController alloc] initWithNibName:@"RUISlideToSleepViewController" bundle:ruiBundle];
    sleep.view.frame = self.view.bounds;
    [self presentModalLayerViewController:sleep animated:YES];
}

/*
- (IBAction)figureEightButtonPressed:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Figure8" ofType:@"sphero"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    //saves a temporary macro command thats includes the data packet
    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
    //Run temporary macro 255
    [RKRunMacroCommand sendCommandWithId:255];
}
*/
- (IBAction)rainbowButtonPressed:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"rainbow" ofType:@"sphero"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    //saves a temporary macro command thats includes the data packet
    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
    //Run temporary macro 255
    [RKRunMacroCommand sendCommandWithId:255];

}

/*
- (IBAction)spinButtonPressed:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"spin" ofType:@"sphero"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    //saves a temporary macro command thats includes the data packet
    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
    //Run temporary macro 255
    [RKRunMacroCommand sendCommandWithId:255];

}

- (IBAction)squareButtonPressed:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Square" ofType:@"sphero"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    //saves a temporary macro command thats includes the data packet
    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
    //Run temporary macro 255
    [RKRunMacroCommand sendCommandWithId:255];
}
*/

//- (IBAction)flipButtonPressed:(id)sender {
//    NSString *file = [[NSBundle mainBundle] pathForResource:@"Flip" ofType:@"sphero"];
//    NSData *data = [NSData dataWithContentsOfFile:file];
//    
//    //saves a temporary macro command thats includes the data packet
//    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
//    //Run temporary macro 255
//    [RKRunMacroCommand sendCommandWithId:255];
//    [RKRollCommand sendCommandWithHeading:0.0 velocity:0.0];
//}

//Color Picker Delegates
//Color picker delegate callbacks
-(void) colorPickerDidChange:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    //Send the color to Sphero when the user picks a new color in the picker
    [RKRGBLEDOutputCommand sendCommandWithRed:r green:g blue:b];
}

-(void) colorPickerDidFinish:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    [controller dismissModalViewControllerAnimated:YES];
}

//Open the Orentation Help view as a modal.  
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
