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

@implementation ForFunViewController
@synthesize connectionLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /*Register for application lifecycle notifications so we known when to connect and disconnect from the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    /*Only start the blinking loop when the view loads*/
    robotOnline = NO;
    noSpheroViewShowing = NO;
    robotDelay = 900.0;
    
    [self setupRobotConnection];
}

- (void)viewDidUnload
{
    connectionLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
}

-(void)appDidBecomeActive:(NSNotification*)notification {
    /*When the application becomes active after entering the background we try to connect to the robot*/
    [self setupRobotConnection];
}

#pragma mark- Sphero Connections

- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    connectionLabel.text = @"CONNECTED";
    
    if(!robotOnline) {
        robotOnline = YES;
        /*Only start the blinking loop once*/
        //[self toggleLED];
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

- (void)toggleLED {
    /*Toggle the LED on and off*/
    if (ledON) {
        ledON = NO;
        [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    } else {
        ledON = YES;
        [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:1.0];
    }
    // Only continue funciton if we are connect to robot
    if( robotOnline ) [self performSelector:@selector(toggleLED) withObject:nil afterDelay:0.5];
}

-(void)showNoSpheroConnectedView {
    if( robotOnline ) return;
    //RobotUIKit resources like images and nib files stored in an external bundle and the path must be specified
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    NSBundle* ruiBundle = [NSBundle bundleWithPath:ruirespath];
    
    NSString* nibName;
    // Set up for iPhone/ipod
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Change if your app is portrait
        nibName = @"RUINoSpheroConnectedViewController_Portrait";
        //nibName = @"RUINoSpheroConnectedViewController_Landscape";
    }
    // Set up for iPad
    else {
        // Change if your app is portrait
        nibName = @"RUINoSpheroConnectedViewController_iPad_Portrait";
        // nibName = @"RUINoSpheroConnectedViewController_iPad_Landscape";
    }
    
    noSpheroView = [[RUINoSpheroConnectedViewController alloc]
                    initWithNibName:nibName
                    bundle:ruiBundle];
    [self presentModalLayerViewController:noSpheroView animated:YES];
    noSpheroViewShowing = YES;
}

//Create a macro that changes the ball colors from:
//ING Orange -> CapOne Blue -> Cap One Red -> Loop between Cap one Red/Blue
//NOTE:  You have to divide the RGB values below by 255 when using UIColor colorWithRGB...
/*******
 ING Orange:  #F86000
 R: 248
 G: 96
 B: 0
 
 Cap Blue:  #003A6F
 R: 0
 G: 57
 B: 110
 
 Cap Red:  #A12830
 R: 160 / 255
 G: 40
 B: 47
 
 Blue Button:
 Gradient Top:  #156599
 Gradient Bottom:  #003A6F
 Border: #003A6F
*********/
- (IBAction)colorMacroButtonPressed:(id)sender {
    
    //Colors Fade during action (Circle)
    //Slew(Fade) is a parrelell command
    //When Slew action is performed, either have it run parrallel to a roll command or a delay.
    //If the user was to include a blink color it would then end the slew abrutly.
        //Create a new macro object to send to Sphero
    
        RKMacroObject *macro = [RKMacroObject new];
        //Sets loop from slider value
        [macro addCommand:[RKMCLoopFor commandWithRepeats:5]];
        //Fade color to Orange
        [macro addCommand:[RKMCSlew commandWithRed:0.97 green:0.37 blue:0.0 delay:robotDelay]];
        //Add delay to allow Fade to complete before playing next fade
        [macro addCommand:[RKMCDelay commandWithDelay:robotDelay]];
        //Fade color to Blue
        [macro addCommand:[RKMCSlew commandWithRed:0.0 green:0.22 blue:0.43 delay:robotDelay]];
        //Add delay to allow Fade to complete before playing next fade
        [macro addCommand:[RKMCDelay commandWithDelay:robotDelay]];
        //Fade color to Red
        [macro addCommand:[RKMCSlew commandWithRed:0.62 green:0.16 blue:0.18 delay:robotDelay]];
        //Add delay to allow Fade to complete before playing next fade
        [macro addCommand:[RKMCDelay commandWithDelay:robotDelay]];
        //Loop End
        [macro addCommand:[RKMCLoopEnd command]];
        //Send full command dowm to Sphero to play
        [macro playMacro];
        //Release Macro
}
@end
