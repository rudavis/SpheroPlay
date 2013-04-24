//
//  HomeTableViewController.m
//  SpheroPlay
//
//  Created by Russ Davis on 4/13/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import "HomeTableViewController.h"
#import "ForSpendingViewController.h"

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set the tableView background image
    self.tableView.backgroundColor=[UIColor clearColor];
    UIImage *backgroundImage = [UIImage imageNamed:@"light_gray_bg.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:backgroundImage];
    self.tableView.backgroundView=backgroundImageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
