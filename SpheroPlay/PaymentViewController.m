//
//  PaymentViewController.m
//  SpheroPlay
//
//  Created by Nookala, Srinivas on 5/8/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "PaymentViewController.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController
@synthesize amount;

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *dataStr = [NSString stringWithFormat:@"Payment of $%@ recieved", self.amount.text];
    [dict setValue:dataStr forKey:@"PAY"];
    
    [[RKMultiplayer sharedMultiplayer] sendDataToAll:dict];
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
