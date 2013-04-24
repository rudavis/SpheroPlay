//
//  ForFunViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForFunViewController : UIViewController {
    BOOL robotOnline;
}

- (IBAction)colorMacroButtonPressed:(id)sender;

-(void)setupRobotConnection;
-(void)handleRobotOnline;

@end
