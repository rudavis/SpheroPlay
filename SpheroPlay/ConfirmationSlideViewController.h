//
//  ConfirmationSlideViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForSlidingViewController.h"

@interface ConfirmationSlideViewController : UIViewController <ForSlidingViewControllerProtocol> {
    int packetCount;
    float robotDelay;
}
- (IBAction)homeButtonPressed:(id)sender;
- (void)successMacro;
- (void)failureMacro;

@end
