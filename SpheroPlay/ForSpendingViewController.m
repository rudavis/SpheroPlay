//
//  ForSpendingViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/23/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "ForSpendingViewController.h"

@interface ForSpendingViewController ()

@end

@implementation ForSpendingViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)passButtonPressed:(id)sender {
}

- (IBAction)payButtonPressed:(id)sender {
}

#pragma mark-Sphero Connection
- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline) {
        // Robot Initializationg State Code Goes Here
    }
    robotOnline = YES;
}

-(void)setupRobotConnection {
    /*Try to connect to the robot*/
/*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
*/
}

@end
