
#import <UIKit/UIKit.h>
#import <RobotKit/RobotKit.h>
#import <RobotUIKit/RobotUIKit.h>
#import <RobotKit/RKMultiplayer.h>

@class RKRemotePlayer;

@interface ForSpendingViewController : UIViewController <RUIColorPickerDelegate, RKMultiplayerDelegateProtocol> {
    IBOutlet UIButton   *passButton;
    IBOutlet UILabel    *connectionMessage;
    RKRemotePlayer      *remotePlayer;
    
    BOOL robotOnline;
    BOOL ballMoving;
}


-(void)controlLoop;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundControlHider;

//Driving Methods
- (IBAction)zeroPressed:(id)sender;
- (IBAction)fortyFivePressed:(id)sender;
- (IBAction)ninetyPressed:(id)sender;
- (IBAction)oneThirtyFivePressed:(id)sender;
- (IBAction)oneEightyPressed:(id)sender;
- (IBAction)twoThirtyFivePressed:(id)sender;
- (IBAction)twoSeventyPressed:(id)sender;
- (IBAction)threeFifteenPressed:(id)sender;
- (IBAction)stopPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *speedSlider;



//Multiplayer Methods
-(IBAction)passPressed;
- (IBAction)endPressed:(id)sender;

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
