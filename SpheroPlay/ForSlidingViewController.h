//
//  ForSlidingViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 4/17/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKDeviceAsyncData;
@protocol ForSlidingViewControllerProtocol <NSObject>

@required
-(void)handleRobotOnline;
-(void)handleAsyncData:(RKDeviceAsyncData *)asyncData;
-(void)sendSetDataStreamingCommand;

@end

@interface ForSlidingViewController : UIViewController {
    BOOL robotOnline;
    int packetCount;
}

@property double combinedAmount;
@property double initialCheckingAmount;
@property double initialSavingsAmount;
@property double newCheckingAmount;
@property double newSavingsAmount;

@property (strong, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkingAmounLabel;
@property (strong, nonatomic) IBOutlet UILabel *savingsAmountLabel;
@property (strong, nonatomic) IBOutlet UISlider *amountSlider;
@property (strong, nonatomic) IBOutlet UIImageView *tiltRightArrow;
@property (strong, nonatomic) IBOutlet UIImageView *tiltLeftArrow;
@property (strong, nonatomic) IBOutlet UIImageView *shakeRightImage;
@property (strong, nonatomic) IBOutlet UIImageView *shakeLeftImage;

- (IBAction)sliderValueChanged:(UISlider *)sender;
- (IBAction)continueButtonPressed:(id)sender;

-(void)setupRobotConnection;



@end
