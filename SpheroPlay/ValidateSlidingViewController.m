//
//  ValidateSlidingViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/17/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ValidateSlidingViewController.h"

@interface ValidateSlidingViewController ()

@end

@implementation ValidateSlidingViewController
@synthesize combinedAmount, initialCheckingAmount, initialSavingsAmount, newCheckingAmount, newSavingsAmount, transferAmount, transferAmountLabel, transferDate,transferDateLabel, fromAccountLabel,toAccountLabel, combinedAmountLabel, updatedSavingsAmountLabel,updatedCheckingAmountLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.newSavingsAmount > self.initialSavingsAmount) {
        //They transfered money into savings.
        
        self.transferAmount = self.newSavingsAmount - self.initialSavingsAmount;
        self.transferAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.transferAmount];
        self.fromAccountLabel.text = [NSString stringWithFormat:@"Checking"];
        [self.fromAccountLabel setTextColor:[UIColor redColor]];
        self.toAccountLabel.text = [NSString stringWithFormat:@"Savings"];
        [self.toAccountLabel setTextColor:[UIColor blueColor]];
                
    } else if (self.newSavingsAmount < self.initialSavingsAmount) {
        //They transfered into checking
        
        self.transferAmount = self.initialSavingsAmount - self.newSavingsAmount;
        self.transferAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.transferAmount];
        self.fromAccountLabel.text = [NSString stringWithFormat:@"Savings"];
        [self.fromAccountLabel setTextColor:[UIColor blueColor]];
        self.toAccountLabel.text = [NSString stringWithFormat:@"Checking"];
        [self.toAccountLabel setTextColor:[UIColor redColor]];
    } else if (self.newSavingsAmount == self.initialSavingsAmount) {
        //They didn't transfer anything
        self.transferAmountLabel.text = [NSString stringWithFormat:@"$0.00"];
        self.fromAccountLabel.text = [NSString stringWithFormat:@"Checking"];
        [self.fromAccountLabel setTextColor:[UIColor redColor]];
        self.toAccountLabel.text = [NSString stringWithFormat:@"Savings"];
        [self.toAccountLabel setTextColor:[UIColor blueColor]];
    }
    
    // Always set the new Savings & Checking amounts
    self.updatedSavingsAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.newSavingsAmount];
    self.updatedCheckingAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.newCheckingAmount];
    self.combinedAmountLabel.text = [NSString stringWithFormat:@"$%.0f", self.combinedAmount];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
