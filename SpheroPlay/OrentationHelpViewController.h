//
//  OrentationHelpViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/25/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrentationHelpViewController;
@protocol OrentationHelpViewControllerDelegate <NSObject>
@end

@interface OrentationHelpViewController : UIViewController

@property id <OrentationHelpViewControllerDelegate> delegate;

- (IBAction)okButtonPressed:(id)sender;

@end
