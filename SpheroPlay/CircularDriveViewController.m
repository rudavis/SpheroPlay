//
//  CircularDriveViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 5/7/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "CircularDriveViewController.h"
#import "RobotKit/RobotKit.h"
#import "RobotUIKit/RobotUIKit.h"


@implementation CircularDriveViewController
@synthesize timeRemainingLabel, counterRemaingLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*Only start the blinking loop when the view loads*/
    robotOnline = NO;
    
    //Start the timer
    currMin = 0;
    currSec = 60;
    
    [timeRemainingLabel setText:@"Get Ready...Set.."];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
        [timeRemainingLabel setText:@"Time Remaining:"];
    });
    [self setupRobotConnection];
}

-(void)timerFired
{
    if((currMin>0 || currSec>=0) && currMin>=0)
    {
        if(currSec==0)
        {
            currMin-=1;
            currSec=60;
        }
        else if(currSec>0)
        {
            currSec-=1;
        }
        if(currMin>-1)
            [counterRemaingLabel setText:[NSString stringWithFormat:@"%d%@%02d",currMin,@":",currSec]];
    }
    else
    {
        [timer invalidate];
        //END Game
        [self timerDidEnd];
    }
}

- (void) timerDidEnd {
    [timeRemainingLabel setText:@"Game Over"];
    [timeRemainingLabel setTextColor:[UIColor redColor]];
    [counterRemaingLabel setText:@"Deposit another quarter"];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
    });

}
- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    robotOnline = YES;
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];
    
    //Setup joystick driving
    [RKDriveControl sharedDriveControl].joyStickSize = circularView.bounds.size;
    [RKDriveControl sharedDriveControl].driveTarget = self;
    [RKDriveControl sharedDriveControl].driveConversionAction = @selector(updateMotionIndicator:);
    [[RKDriveControl sharedDriveControl] startDriving:RKDriveControlJoyStick];
    //Set max speed
    [RKDriveControl sharedDriveControl].velocityScale = 0.6;
    
    // start processing the puck's movements
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleJoystickMotion:)];
    [drivePuck addGestureRecognizer:panGesture];
}

-(void)setupRobotConnection {
    /*Try to connect to the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
}


#pragma mark -
#pragma mark Joystick related methods

- (void)handleJoystickMotion:(id)sender
{
    //Don't handle the gesture if we aren't connected to and driving a robot
    if (![RKDriveControl sharedDriveControl].driving) return;
    
    //Handle the pan gesture and pass the results into the drive control
    UIPanGestureRecognizer *pan_recognizer = (UIPanGestureRecognizer *)sender;
    CGRect parent_bounds = circularView.bounds;
    CGPoint parent_center = [circularView convertPoint:circularView.center fromView:circularView.superview] ;
    
    if (pan_recognizer.state == UIGestureRecognizerStateEnded || pan_recognizer.state == UIGestureRecognizerStateCancelled || pan_recognizer.state == UIGestureRecognizerStateFailed || pan_recognizer.state == UIGestureRecognizerStateBegan) {
        ballMoving = NO;
        [[RKDriveControl sharedDriveControl].robotControl stopMoving];
        drivePuck.center = parent_center;
    } else if (pan_recognizer.state == UIGestureRecognizerStateChanged) {
        ballMoving = YES;
        CGPoint translate = [pan_recognizer translationInView:circularView];
        CGPoint drag_point = parent_center;
        drag_point.x += translate.x;
        drag_point.y += translate.y;
        drag_point.x = [self clampWithValue:drag_point.x min:CGRectGetMinX(parent_bounds) max:CGRectGetMaxX(parent_bounds)];
        drag_point.y = [self clampWithValue:drag_point.y min:CGRectGetMinY(parent_bounds) max:CGRectGetMaxY(parent_bounds)];
        [[RKDriveControl sharedDriveControl] driveWithJoyStickPosition:drag_point];
    }
}

- (void)updateMotionIndicator:(RKDriveAlgorithm*)driveAlgorithm {
    //Don't update the puck position if we aren't driving
    if ( ![RKDriveControl sharedDriveControl].driving || !ballMoving) return;
    
    //Update the joystick puck position based on the data from the drive algorithm
    CGRect bounds = circularView.bounds;
    
    double velocity = driveAlgorithm.velocity/driveAlgorithm.velocityScale;
	double angle = driveAlgorithm.angle + (driveAlgorithm.correctionAngle * 180.0/M_PI);
	if (angle > 360.0) {
		angle -= 360.0;
	}
    double x = ((CGRectGetMaxX(bounds) - CGRectGetMinX(bounds))/2.0) *
    (1.0 + velocity * sin(angle * M_PI/180.0));
    double y = ((CGRectGetMaxY(bounds) - CGRectGetMinY(bounds))/2.0) *
    (1.0 - velocity * cos(angle * M_PI/180.0));
	
    CGPoint center = CGPointMake(floor(x), floor(y));
    
    [UIView setAnimationsEnabled:NO];
    drivePuck.center = center;
    [UIView setAnimationsEnabled:YES];
}

- (float)clampWithValue:(float)value min:(float)min max:(float)max {
    //A standard clamp function
    if (value < min) {
        return min;
    } else if (value > max) {
        return max;
    } else {
        return value;
    }
}
#pragma mark -
#pragma mark UI Interaction

-(IBAction)colorPressed:(id)sender {
    //RobotUIKit resources like images and nib files stored in an external bundle and the path must be specified
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    NSBundle* ruiBundle = [NSBundle bundleWithPath:ruirespath];
    
    //Present the color picker and set the starting color to white
    RUIColorPickerViewController *colorPicker = [[RUIColorPickerViewController alloc] initWithNibName:@"RUIColorPickerViewController" bundle:ruiBundle];
    [colorPicker setCurrentRed:1.0 green:1.0 blue:1.0];
    colorPicker.delegate = self;
    colorPicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [colorPicker layoutPortrait];
    [self presentViewController:colorPicker animated:YES completion:nil];
}

- (IBAction)rainbowButtonPressed:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"rainbow" ofType:@"sphero"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    //saves a temporary macro command thats includes the data packet
    [RKSaveTemporaryMacroCommand sendCommandWithMacro:data flags:RKMacroFlagMotorControl];
    //Run temporary macro 255
    [RKRunMacroCommand sendCommandWithId:255];
}

//Color picker delegate callbacks
-(void) colorPickerDidChange:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    //Send the color to Sphero when the user picks a new color in the picker
    [RKRGBLEDOutputCommand sendCommandWithRed:r green:g blue:b];
}


-(void) colorPickerDidFinish:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    [RKRGBLEDOutputCommand sendCommandWithRed:r green:g blue:b];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
