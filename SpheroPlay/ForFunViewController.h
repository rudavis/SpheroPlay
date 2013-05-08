//
//  ForFunViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RobotUIKit/RobotUIKit.h>

@interface ForFunViewController : UIViewController <RUIColorPickerDelegate, RUICalibrateButtonGestureHandlerProtocol> {
    BOOL robotOnline;
    BOOL robotInitialized;
    BOOL noSpheroViewShowing;
    float robotDelay;
    UILabel *connetionLabel;
    
    RUINoSpheroConnectedViewController* noSpheroView;
}
@property (nonatomic, retain) IBOutlet UILabel* connectionLabel;

-(void)setupRobotConnection;
-(void)handleRobotOnline;


- (IBAction)colorButtonPressed:(id)sender;
- (IBAction)sleepButtonPressed:(id)sender;
//- (IBAction)figureEightButtonPressed:(id)sender;
- (IBAction)rainbowButtonPressed:(id)sender;

//- (IBAction)spinButtonPressed:(id)sender;
//- (IBAction)squareButtonPressed:(id)sender;


@end
