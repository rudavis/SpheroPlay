//
//  PiggyBankViewController.h
//  SpheroPlay
//
//  Created by Russ Davis on 5/2/13.
//  Copyright (c) 2013 RTB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKDeviceAsyncData;
@interface PiggyBankViewController : UIViewController {
    int packetCount;
}

-(void)sendSetDataStreamingCommand;
-(void)handleAsyncData:(RKDeviceAsyncData *)asyncData;

-(void)playSound;

@end
