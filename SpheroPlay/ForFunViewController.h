//
//  ForFunViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RobotUIKit/RobotUIKit.h>

@interface ForFunViewController : UIViewController {
    BOOL ledON;
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
-(void)toggleLED;

- (IBAction)colorMacroButtonPressed:(id)sender;

@end
