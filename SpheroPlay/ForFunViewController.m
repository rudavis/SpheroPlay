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
}

- (IBAction)colorButtonPressed:(id)sender {
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    RUIColorPickerViewController *cpc = [[RUIColorPickerViewController alloc] initWithNibName:@"RUIColorPickerViewController" bundle:[NSBundle bundleWithPath:ruirespath]];
    cpc.delegate = self;
    cpc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [cpc layoutPortrait];
    [cpc setRed:1.0 green:1.0 blue:1.0];

    //[cpc showBackButton:YES];
    //[cpc setBackButtonTarget:self action:@selector(colorPickerDidPressBack)];
    
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [customButton addTarget:self action:@selector(customButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [customButton setTitle:@"Pay" forState:UIControlStateNormal];
    customButton.frame = CGRectMake(10, 10, 40, 40);
    
    [self presentModalViewController:cpc animated:YES];
    
    [cpc.view addSubview:customButton];
}


- (IBAction)successMacroButtonPressed:(id)sender {
    RKMacroObject *macro = [RKMacroObject new];
    [macro addCommand:[RKMCSlew commandWithRed:1.0 green:1.0 blue:1.0 delay:0]];
    
    //Fade to white, pause, blue, pause
    //White
    [macro addCommand:[RKMCSlew commandWithRed:1.0 green:1.0 blue:1.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];
    //Blue
    [macro addCommand:[RKMCSlew commandWithRed:0.0 green:0.0 blue:1.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];
    //White
    [macro addCommand:[RKMCSlew commandWithRed:1.0 green:1.0 blue:1.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];
    //Blue
    [macro addCommand:[RKMCSlew commandWithRed:0.0 green:0.0 blue:1.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];
    
    //Green
    [macro addCommand:[RKMCSlew commandWithRed:0.0 green:1.0 blue:0.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];
    [macro addCommand:[RKMCRGB commandWithRed:0.0 green:1.0 blue:0.0 delay:0]];
        
    //Send full command dowm to Sphero to play
    [macro playMacro];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];
}

- (IBAction)failureMacroButtonPressed:(id)sender {
    RKMacroObject *macro = [RKMacroObject new];
    [macro addCommand:[RKMCSlew commandWithRed:1.0 green:1.0 blue:1.0 delay:0]];
    
    //Fade to white, pause, blue, pause
    //White
    [macro addCommand:[RKMCSlew commandWithRed:1.0 green:1.0 blue:1.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];
    //Blue
    [macro addCommand:[RKMCSlew commandWithRed:0.0 green:0.0 blue:1.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];
    //White
    [macro addCommand:[RKMCSlew commandWithRed:1.0 green:1.0 blue:1.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];
    //Blue
    [macro addCommand:[RKMCSlew commandWithRed:0.0 green:0.0 blue:1.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay*2]];

    
    //Red
    [macro addCommand:[RKMCSlew commandWithRed:1.0 green:0.0 blue:0.0 delay:robotDelay]];
    [macro addCommand:[RKMCDelay commandWithDelay:robotDelay]];
    [macro addCommand:[RKMCRGB commandWithRed:1.0 green:0.0 blue:0.0 delay:0]];
    [macro playMacro];
    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0];
}

//Color Picker Delegates
//Color picker delegate callbacks
-(void) colorPickerDidChange:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    //Send the color to Sphero when the user picks a new color in the picker
    [RKRGBLEDOutputCommand sendCommandWithRed:r green:g blue:b];
}

-(void) colorPickerDidFinish:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    [controller dismissModalViewControllerAnimated:YES];
}

-(void) colorPickerDidPressBack {
    NSLog(@"Pressed Back");
}

-(void) customButtonPressed {
    NSLog(@"Custom Pressed Back");
}



//Open the Orentation Help view as a modal.  
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
