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
@synthesize speedSlider, backgroundControlHider;

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
    [RKRemotePlayer setMaxPingTimeouts:50];
    [RKRemotePlayer setPingTimeout:50.0];
    [[RKMultiplayer sharedMultiplayer] stopGettingAvailableMultiplayerGames];
    [[RKMultiplayer sharedMultiplayer] hostGameOfType:TwoPhonesGameType playerName:@"TwoPhonesOneBall"];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [RKMultiplayer setMultiplayerDebug:YES];
    
    self.navigationItem.hidesBackButton = YES;
    
    //Hide dirve controls until game starts
    backgroundControlHider.hidden = NO;
    robotOnline = NO;
    
    [RKRemotePlayer setMaxPingTimeouts:50];
    [RKRemotePlayer setPingTimeout:50.0];
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
    //cpc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [cpc layoutPortrait];
    [cpc setRed:1.0 green:1.0 blue:1.0];
    [cpc showRollButton:NO];
    
    //[self presentViewController:cpc animated:YES completion:nil];
    cpc.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:cpc animated:YES];

}

- (IBAction)endPressed:(id)sender {
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
        backgroundControlHider.hidden = YES;
        
        
        //If we aren't the host we want to go to the flipside view until control is passed to us
        if(![[RKMultiplayer sharedMultiplayer] isHost]) {
            NSString* rootpath = [[NSBundle mainBundle] bundlePath];
            NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
            RUIColorPickerViewController *cpc = [[RUIColorPickerViewController alloc] initWithNibName:@"RUIColorPickerViewController" bundle:[NSBundle bundleWithPath:ruirespath]];
            cpc.delegate = self;
            //cpc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [cpc layoutPortrait];
            [cpc setRed:1.0 green:1.0 blue:1.0];
            [cpc showRollButton:NO];

            cpc.navigationItem.hidesBackButton = YES;
            [self.navigationController pushViewController:cpc animated:YES];
       
        }
        //Start the RCDrive control loop
        [self controlLoop];
    } else if(newState==RKMultiplayerGameStateEnded) {
        //If a the other user disconnects the game is over
        [[RKMultiplayer sharedMultiplayer] leaveCurrentGame];
        
        //Reset the UI
        connectionMessage.hidden = NO;
        backgroundControlHider.hidden = NO;
        
        //Dismiss the color picker if it is on screen
        if([self.title isEqualToString: @"Color Picker"]) {
            [self.navigationController popViewControllerAnimated:YES];
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
    NSDictionary *payload = [data objectForKey:@"PAYLOAD"];

    if([[payload valueForKey:@"PASS"] isEqualToString:@"ur turn"]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([payload objectForKey:@"PAY"]) {
        //NSString *amountPaid = [payload valueForKey:@"AMOUNT"];
        NSString *payString = [payload valueForKey:@"PAY"];
        //NSLog(@"Trying to is trying to pay you: %@", payString);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You got $$$"
                                                        message:payString
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}


//Button Driving Methods
- (IBAction)zeroPressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:0.0 velocity:speedSlider.value];
    //Important, determine if we're the host or the guest and post the command.
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}

- (IBAction)fortyFivePressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:45.0 velocity:speedSlider.value];
    //Important, determine if we're the host or the guest and post the command.
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}

- (IBAction)ninetyPressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:90.0 velocity:speedSlider.value];
    //Important, determine if we're the host or the guest and post the command.
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}

- (IBAction)oneThirtyFivePressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:135.0 velocity:speedSlider.value];
    //Important, determine if we're the host or the guest and post the command.
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}

- (IBAction)oneEightyPressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:180.0 velocity:speedSlider.value];
    //Important, determine if we're the host or the guest and post the command.
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}

- (IBAction)twoThirtyFivePressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:235.0 velocity:speedSlider.value];
    //Important, determine if we're the host or the guest and post the command.
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}

- (IBAction)twoSeventyPressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:270.0 velocity:speedSlider.value];
    //Important, determine if we're the host or the guest and post the command.
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}
- (IBAction)threeFifteenPressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:315.0 velocity:speedSlider.value];
    //Important, determine if we're the host or the guest and post the command.
    if([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}

- (IBAction)stopPressed:(id)sender {
    RKRollCommand *command = [[RKRollCommand alloc] initWithHeading:0.0 velocity:0.0];
    if ([[RKMultiplayer sharedMultiplayer] isHost]) {
        [[RKDeviceMessenger sharedMessenger] postCommand:command];
    } else {
        [remotePlayer.robot sendCommand:command];
    }
}
@end
