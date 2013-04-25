//
//  OrentationHelpViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/25/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "OrentationHelpViewController.h"

@interface OrentationHelpViewController ()

@end

@implementation OrentationHelpViewController
@synthesize delegate;

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

- (IBAction)okButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
