//
//  ForSlidingViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/17/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "ForSlidingViewController.h"
#import "ValidateSlidingViewController.h"

@interface ForSlidingViewController ()

@end

@implementation ForSlidingViewController
@synthesize totalAmountLabel, checkingAmounLabel, savingsAmountLabel, amountSlider;
@synthesize combinedAmount, initialCheckingAmount, initialSavingsAmount, newCheckingAmount, newSavingsAmount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set initial Amounts
    combinedAmount = 1000.0;
    initialCheckingAmount = 550.00;
    initialSavingsAmount = combinedAmount - initialCheckingAmount;
    
    //Set label values from initial amounts
    totalAmountLabel.text = [NSString stringWithFormat:@"Total:  %.0f", combinedAmount];
    checkingAmounLabel.text = [NSString stringWithFormat:@"Checking: %.0f", initialCheckingAmount];
    savingsAmountLabel.text = [NSString stringWithFormat:@"Savings: %.0f", initialSavingsAmount];
    
    //Set the slider values
    amountSlider.minimumValue = 0.0;
    amountSlider.maximumValue = combinedAmount;
    amountSlider.value = initialCheckingAmount;
    
    //Customize Slider
    UIImage *minImage = [[UIImage imageNamed:@"red_slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"blue_slider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    UIImage *thumbImage = [UIImage imageNamed:@"dollar_sign.gif"];
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    double savingsAmount = [sender maximumValue] - [sender value];
    
    checkingAmounLabel.text = [NSString stringWithFormat:@"Checking: %.0f", [sender value]];
    savingsAmountLabel.text = [NSString stringWithFormat:@"Savings: %.0f", savingsAmount];
}

- (IBAction)continueButtonPressed:(id)sender {
    newCheckingAmount = amountSlider.value;
    newSavingsAmount = combinedAmount - newCheckingAmount;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"validateSlideSegue"]) {

        newCheckingAmount = amountSlider.value;
        newSavingsAmount = combinedAmount - newCheckingAmount;
        
        ValidateSlidingViewController *destViewController = segue.destinationViewController;

        destViewController.combinedAmount = combinedAmount;
        destViewController.initialCheckingAmount = initialCheckingAmount;
        destViewController.initialSavingsAmount = initialSavingsAmount;
        destViewController.newCheckingAmount = newCheckingAmount;
        destViewController.newSavingsAmount = newSavingsAmount;
    }
}

@end
