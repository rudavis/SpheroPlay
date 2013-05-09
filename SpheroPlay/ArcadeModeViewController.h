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
{
    float creditsRemaining; 
}
@property (strong, nonatomic) IBOutlet UIImageView *quarterImage;
@property (strong, nonatomic) IBOutlet UIImageView *slotImage;
@property (strong, nonatomic) IBOutlet UILabel *creditsLabel;
@property (strong, nonatomic) IBOutlet UIButton *addCreditsButton;

-(IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (void) coinDroppedInSlot;
- (IBAction)addCreditsButtonPressed:(id)sender;

@end
