//
//  ArcadeModeViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 5/3/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArcadeModeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *quarterImage;
@property (strong, nonatomic) IBOutlet UIImageView *slotImage;

-(IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (void) coinDroppedInSlot;

@end
