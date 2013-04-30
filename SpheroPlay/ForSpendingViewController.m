//
//  MainViewController.m
//  TwoPhonesOneBall
//
//  Created by Jon Carroll on 8/12/11.
//  Copyright 2011 Orbotix, Inc. All rights reserved.
//

#import "ForSpendingViewController.h"
#import "RobotKit/RobotKit.h"
#import "RobotUIKit/RobotUIKit.h"


static NSString * const TwoPhonesGameType = @"twophones";

@implementation ForSpendingViewController


#pragma mark -
#pragma mark Memory Management

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Robot Online Notification

-(void)handleConnectionOnline:(NSNotification*)notification {
    //This is the notificaiton we get when we find out the robot is online
    //Robot will not respond to commands until this notification is recieved
    connectionMessage.text = @"Waiting for other player to join...";
    [[RKMultiplayer sharedMultiplayer] stopGettingAvailableMultiplayerGames];
    [[RKMultiplayer sharedMultiplayer] hostGameOfType:TwoPhonesGameType playerName:@"TwoPhonesOneBall"];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Hide dirve controls until game starts
    driveWheel.hidden = YES;
    passButton.hidden = YES;
    robotOnline = NO;
    
    //Set the multiplayer delegate to this controller (RKMultiplayer can only have one delegate at a time)
    [[RKMultiplayer sharedMultiplayer] setDelegate:self];
    
    connectionMessage.text = @"Looking for players with robots...";
    [[RKMultiplayer sharedMultiplayer] getAvailableMultiplayerGamesOfType:TwoPhonesGameType];
    
    // Watch for online notification to start driving
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionOnline:) name:RKDeviceConnectionOnlineNotification object:nil];
    
    
    //Attempt to control the connected robot so we get the notification if one is connected
	[[RKRobotProvider sharedRobotProvider] controlConnectedRobot];
	
}

#pragma mark -
#pragma mark RCDrive Controls


/********** Start Here ***********/
-(void)controlLoop {

    robotOnline = YES;
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

/*
    //Fires every 0.2 seconds on a timer to get readings from the sliders and send roll commands to the ball
    
    float speed = speedSlider.value*speedSlider.value; //RCDrive controls work best if speed is on exponential curve
    
    float headingAdjustment = 30.0 * headingSlider.value; //Only adjust heading by up to 30 degrees every 0.2 seconds
    heading += headingAdjustment;
    if(heading < 0.0) heading += 359.0;
    if(heading > 359.0) heading -= 359.0;
    
    if(speed == lastSpeed && heading == lastHeading) {
        [self performSelector:@selector(controlLoop) withObject:nil afterDelay:0.2];
        return;
    }
    lastSpeed = speed;
    lastHeading = heading;
    
    if(!self.modalViewController) { //Be sure that we have control of the robot
        RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:heading velocity:speed];
        //This is the important part where we decide if we send the command to the local robot or the remote robot
        if([[RKMultiplayer sharedMultiplayer] isHost]) {
            //If we are the host we send it to our local robot
            [[RKDeviceMessenger sharedMessenger] postCommand:command];
        } else {
            //If we aren't the host we send it to the host's robot like this...
            [remotePlayer.robot sendCommand:command];
        }
        [command release];
    }
    
    [self performSelector:@selector(controlLoop) withObject:nil afterDelay:0.2];
*/
}

#pragma mark -
#pragma mark Joystick related methods

- (void)handleJoystickMotion:(id)sender
{
    //Don't handle the gesture if we aren't connected to and driving a robot
    //if (![RKDriveControl sharedDriveControl].driving) return;
    NSLog(@"got into joystick");
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
    //if ( ![RKDriveControl sharedDriveControl].driving || !ballMoving) return;

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
#pragma mark Pass Button Pressed

- (IBAction)passPressed
{
    //Send the message to our opponent indicating we are passing control of the robot to them
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"ur turn" forKey:@"PASS"];
    [[RKMultiplayer sharedMultiplayer] sendDataToAll:dict];
    
    //Hide the robot controls and present the color picker since we don't have control
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    RUIColorPickerViewController *cpc = [[RUIColorPickerViewController alloc] initWithNibName:@"RUIColorPickerViewController" bundle:[NSBundle bundleWithPath:ruirespath]];
    cpc.delegate = self;
    cpc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [cpc layoutPortrait];
    [cpc setRed:1.0 green:1.0 blue:1.0];
    [self presentViewController:cpc animated:YES completion:nil];
    
}

#pragma mark -
#pragma mark RUIColorPickerDelegate methods

-(void) colorPickerDidChange:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    RKRGBLEDOutputCommand *command = [[RKRGBLEDOutputCommand alloc] initWithRed:r green:g blue:b];
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}

#pragma mark -
#pragma mark RKMultiplayer Delegate Methods

//This is the callback when multiplayer games for your app are found.  You might use this callback to display the available games in a tableview or autmatically join the first game found such as in this case
-(void)multiplayerDidUpdateAvailableGames:(NSArray*)games {
    NSLog(@"did update available games");
    
    //If there is at least one available game to join
    if([games count] > 0) {
        RKMultiplayerGame *game = [games objectAtIndex:0];
        //We want to stop updating the list of available multiplayer games now that we found one
        [[RKMultiplayer sharedMultiplayer] stopGettingAvailableMultiplayerGames];
        
        //We want to join the advertised game we found
        [[RKMultiplayer sharedMultiplayer] joinAdvertisedGame:game];
    }
}

//Sent to all clients in a game when another joins for updating UI
-(void)multiplayerPlayerDidJoinGame:(RKRemotePlayer*)player {
    //Save an ivar to the remote player
    remotePlayer = player;
    
    //If we are the host (device with robot connected) we need to start the game at this point
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKMultiplayer sharedMultiplayer] startGame];
    }
}


//Sent on game state change for updating UI
-(void)multiplayerGameStateDidChangeToState:(RKMultiplayerGameState)newState {
    if(newState==RKMultiplayerGameStateStarted) {

        connectionMessage.hidden = YES;
        driveWheel.hidden = NO;
        passButton.hidden = NO;
        //If we aren't the host we want to go to the flipside view until control is passed to us
        if(![[RKMultiplayer sharedMultiplayer] isHost]) {
            NSString* rootpath = [[NSBundle mainBundle] bundlePath];
            NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
            RUIColorPickerViewController *cpc = [[RUIColorPickerViewController alloc] initWithNibName:@"RUIColorPickerViewController" bundle:[NSBundle bundleWithPath:ruirespath]];
            cpc.delegate = self;
            cpc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [cpc layoutPortrait];
            [cpc setRed:1.0 green:1.0 blue:1.0];
            [self presentViewController:cpc animated:YES completion:nil];
        }
        //Start the RCDrive control loop
        [self controlLoop];
    } else if(newState==RKMultiplayerGameStateEnded) {
        //If a the other user disconnects the game is over
        [[RKMultiplayer sharedMultiplayer] leaveCurrentGame];
        
        //Reset the UI
        connectionMessage.hidden = NO;
        passButton.hidden = YES;
        driveWheel.hidden = YES;
        
        //Dismiss the color picker if it is on screen
        if(self.modalViewController) {
            [self dismissModalViewControllerAnimated:NO];
        }
        
        //Look for other games or host a new one depending on if we had a ball
        if([[RKMultiplayer sharedMultiplayer] isHost]) {
            [[RKMultiplayer sharedMultiplayer] hostGameOfType:TwoPhonesGameType playerName:@"TwoPhonesOneBall"];
        } else {
            [[RKMultiplayer sharedMultiplayer] getAvailableMultiplayerGamesOfType:TwoPhonesGameType];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"The other player has disconnected, the game is over" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

//Called when game data is recieved from another player
-(void)multiplayerDidRecieveGameData:(NSDictionary*)data {
    //The responses recieved here have the payload we passed in wrapped in routing information about the sender and reciever
    //What we passed in is stored in a dictionary with the key payload, we will need to pull it out
    NSDictionary *payload = [data objectForKey:@"PAYLOAD"];
    if([[payload valueForKey:@"PASS"] isEqualToString:@"ur turn"]) {
        //The other player has sent us the message indicating control of the robot has been passed to us, dismiss the modal view
        [self dismissModalViewControllerAnimated:YES];
    }
}


@end
