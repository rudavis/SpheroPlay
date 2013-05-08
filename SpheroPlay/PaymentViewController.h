//
//  PaymentViewController.h
//  SpheroPlay
//
//  Created by Nookala, Srinivas on 5/8/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RobotKit/RKMultiplayer.h>

@interface PaymentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *amount;

- (IBAction)submitAction:(id)sender;

- (IBAction)cancelAction:(id)sender;


@end
