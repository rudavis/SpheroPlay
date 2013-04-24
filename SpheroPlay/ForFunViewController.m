//
//  ForFunViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "ForFunViewController.h"
//#import "RobotKit/RobotKit.h"
//#import "RobotKit/RKMacroObject.h"
//#import "RobotKit/RKAbortMacroCommand.h"

@interface ForFunViewController ()

@end

@implementation ForFunViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-Sphero Connection
- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline) {
        // Robot Initializationg State Code Goes Here
    }
    robotOnline = YES;
}

-(void)setupRobotConnection {
    /*Try to connect to the robot*/
/*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
*/
}


//Create a macro that changes the ball colors from:
//ING Orange -> CapOne Blue -> Cap One Red -> Loop between Cap one Red/Blue
//NOTE:  You have to divide the RGB values below by 255 when using UIColor colorWithRGB...
/*******
 Cap Red:  #A12830
 R: 160 / 255
 G: 40
 B: 47
 
 Cap Blue:  #003A6F
 R: 0
 G: 57
 B: 110
 
 ING Orange:  #F86000
 R: 248
 G: 96
 B: 0
 
 Blue Button:
 Gradient Top:  #156599
 Gradient Bottom:  #003A6F
 Border: #003A6F
*********/
- (IBAction)colorMacroButtonPressed:(id)sender {
    
/*
    //Colors Fade during action (Circle)
    //Slew(Fade) is a parrelell command
    //When Slew action is performed, either have it run parrallel to a roll command or a delay.
    //If the user was to include a blink color it would then end the slew abrutly.
    -(IBAction)MacroColor:(id)sender{
        //Create a new macro object to send to Sphero
        RKMacroObject *macro = [RKMacroObject new];
        //Sets loop from slider value
        [macro addCommand:[RKMCLoopFor commandWithRepeats:robotLoop]];
        //Fade color to Blue
        [macro addCommand:[RKMCSlew commandWithRed:0.0 green:0.0 blue:1.0 delay:robotDelay]];
        //Add delay to allow Fade to complete before playing next fade
        [macro addCommand:[RKMCDelay commandWithDelay:robotDelay]];
        //Fade color to Red
        [macro addCommand:[RKMCSlew commandWithRed:1.0 green:0.0 blue:0.0 delay:robotDelay]];
        //Add delay to allow Fade to complete before playing next fade
        [macro addCommand:[RKMCDelay commandWithDelay:robotDelay]];
        //Fade color to Green
        [macro addCommand:[RKMCSlew commandWithRed:0.0 green:1.0 blue:0.0 delay:robotDelay]];
        //Add delay to allow Fade to complete before playing next fade
        [macro addCommand:[RKMCDelay commandWithDelay:robotDelay]];
        //Loop End
        [macro addCommand:[RKMCLoopEnd command]];
        //Send full command dowm to Sphero to play
        [macro playMacro];
        //Release Macro
        [macro release];
    }
*/
    
    
 
    
}
@end
