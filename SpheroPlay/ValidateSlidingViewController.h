//
//  ValidateSlidingViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/17/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ValidateSlidingViewController : UIViewController

@property double combinedAmount;
@property double initialCheckingAmount;
@property double initialSavingsAmount;
@property double newCheckingAmount;
@property double newSavingsAmount;
@property double transferAmount;
@property NSString *fromAccount;
@property NSString *toAccounts;
@property NSDate *transferDate;


@property (strong, nonatomic) IBOutlet UILabel *transferAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *fromAccountLabel;
@property (strong, nonatomic) IBOutlet UILabel *toAccountLabel;
@property (strong, nonatomic) IBOutlet UILabel *transferDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *updatedCheckingAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *updatedSavingsAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *combinedAmountLabel;


@end
