//
//  TiltHelpViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/26/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TiltHelpViewController;
@protocol TiltHelpViewControllerDelegate <NSObject>
@end

@interface TiltHelpViewController : UIViewController

@property id <TiltHelpViewControllerDelegate> delegate;

- (IBAction)okButtonPressed:(id)sender;

@end
