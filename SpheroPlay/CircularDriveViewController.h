//
//  CircularDriveViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 5/7/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RobotUIKit/RobotUIKit.h>
#import <RobotKit/RobotKit.h>
#import "CircularUIView.h"

@interface CircularDriveViewController : UIViewController <RUIColorPickerDelegate, RUICalibrateButtonGestureHandlerProtocol> {
    
    // Sphero state variables
    BOOL robotOnline;
    BOOL ballMoving;
    BOOL allowCalibrating;
    
    // Controls calibration gestures
    RUICalibrateButtonGestureHandler *calibrateAboveHandler;
    
    // Controls two finger calibration gestures
    RUICalibrateGestureHandler *calibrateTwoFingerHandler;
    
    //Views that make up the drive joystick
    IBOutlet UIView *driveWheel;
    IBOutlet UIImageView *drivePuck;
    IBOutlet CircularUIView *circularView;
    
    // Buttons from NIB that link to a calibration gesture handler
    IBOutlet UIButton *calibrateAboveButton;
    //Game Timers
    int currMin;
    int currSec;
    NSTimer *timer;
}

@property (strong, nonatomic) IBOutlet UILabel *timeRemainingLabel;
@property (strong, nonatomic) IBOutlet UILabel *counterRemaingLabel;

-(void)setupRobotConnection;
-(void)handleRobotOnline;

//Joystick drive related methods
-(float)clampWithValue:(float)value min:(float)min max:(float)max;
-(void)updateMotionIndicator:(RKDriveAlgorithm*)driveAlgorithm;
-(void)handleJoystickMotion:(id)sender;


//UI Interaction
-(IBAction)colorPressed:(id)sender;
-(IBAction)sleepPressed:(id)sender;

@end
