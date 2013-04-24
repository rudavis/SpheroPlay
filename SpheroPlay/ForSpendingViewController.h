//
//  ForSpendingViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularUIView.h"
//#import <RobotUIKit/RobotUIKit.h>
//#import <RobotKit/RobotKit.h>

@interface ForSpendingViewController : UIViewController
{
    //Need to use <RUIColorPickerDelegate, RUICalibrateButtonGestureHandlerProtocol>
    // Sphero state variables
    BOOL robotOnline;
    BOOL ballMoving;
    BOOL allowCalibrating;
    
    // Controls calibration gestures
//    RUICalibrateButtonGestureHandler *calibrateAboveHandler;
    
    // Controls two finger calibration gestures
//    RUICalibrateGestureHandler *calibrateTwoFingerHandler;
    
    //Views that make up the drive joystick
    IBOutlet UIView *driveWheel;
    IBOutlet UIImageView *drivePuck;
    IBOutlet CircularUIView *circularView;
    
    // Buttons from NIB that link to a calibration gesture handler
    IBOutlet UIButton *calibrateAboveButton;
}

//-(void)setupRobotConnection;
//-(void)handleRobotOnline;

//Joystick drive related methods
-(float)clampWithValue:(float)value min:(float)min max:(float)max;
//-(void)updateMotionIndicator:(RKDriveAlgorithm*)driveAlgorithm;
-(void)handleJoystickMotion:(id)sender;


- (IBAction)passButtonPressed:(id)sender;
- (IBAction)payButtonPressed:(id)sender;


@end
