//
//  PiggyBankViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 5/2/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKDeviceAsyncData;
@class PiggyBankViewController;

@protocol PiggyBankViewControllerDelegate <NSObject>

- (void) piggyBankViewController: (PiggyBankViewController *) controller DidPressDone:(float) credits;
- (void) piggyBankViewControllerDidPressCancel: (PiggyBankViewController *) controller;

@end


@interface PiggyBankViewController : UIViewController {
    int packetCount;
    int numberOfShakes;
    float credits;
}

@property (nonatomic, weak) id <PiggyBankViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *creditsLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfShakesLabel;

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;

-(void)sendSetDataStreamingCommand;
-(void)handleAsyncData:(RKDeviceAsyncData *)asyncData;

-(void)playSound;

@end
