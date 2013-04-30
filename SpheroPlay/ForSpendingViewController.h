
#import <UIKit/UIKit.h>
#import <RobotKit/RobotKit.h>
#import <RobotUIKit/RobotUIKit.h>
#import <RobotKit/RKMultiplayer.h>
#import "CircularUIView.h"

@class RKRemotePlayer;

@interface ForSpendingViewController : UIViewController <RUIColorPickerDelegate, RKMultiplayerDelegateProtocol> {
    IBOutlet UIButton   *passButton;
    IBOutlet UILabel    *connectionMessage;
    RKRemotePlayer      *remotePlayer;
    
    
    BOOL robotOnline;
    BOOL ballMoving;
    IBOutlet CircularUIView *circularView;
    IBOutlet UIImageView *drivePuck;
    IBOutlet UIView *driveWheel;
    
}

//Joystick drive related methods
-(float)clampWithValue:(float)value min:(float)min max:(float)max;
-(void)updateMotionIndicator:(RKDriveAlgorithm*)driveAlgorithm;
-(void)handleJoystickMotion:(id)sender;


//Multiplayer Methods
-(IBAction)passPressed;

-(void)controlLoop;

//Called when the available list of multiplayer games has updated
//array contains RKMultiplayerGame objects representing available games
-(void)multiplayerDidUpdateAvailableGames:(NSArray*)games;

//Sent to all clients in a game when another joins for updating UI
-(void)multiplayerPlayerDidJoinGame:(RKRemotePlayer*)player;

//Sent on game state change for updating UI
-(void)multiplayerGameStateDidChangeToState:(RKMultiplayerGameState)newState;

//Called when game data is recieved from another player
-(void)multiplayerDidRecieveGameData:(NSDictionary*)data;


@end
