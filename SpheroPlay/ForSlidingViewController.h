//
//  ForSlidingViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/17/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForSlidingViewController : UIViewController

@property double combinedAmount;
@property double initialCheckingAmount;
@property double initialSavingsAmount;
@property double newCheckingAmount;
@property double newSavingsAmount;

@property (strong, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkingAmounLabel;
@property (strong, nonatomic) IBOutlet UILabel *savingsAmountLabel;
@property (strong, nonatomic) IBOutlet UISlider *amountSlider;

- (IBAction)sliderValueChanged:(UISlider *)sender;
- (IBAction)continueButtonPressed:(id)sender;





@end
