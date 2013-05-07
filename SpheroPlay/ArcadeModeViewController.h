//
//  ArcadeModeViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 5/3/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiggyBankViewController.h"

@interface ArcadeModeViewController : UIViewController <PiggyBankViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *quarterImage;
@property (strong, nonatomic) IBOutlet UIImageView *slotImage;
@property (strong, nonatomic) IBOutlet UILabel *creditsLabel;

-(IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (void) coinDroppedInSlot;

@end
