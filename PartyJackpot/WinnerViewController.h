//
//  WinnerViewController.h
//  PartyJackpot
//
//  Created by Maciek on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person+Helper.h"

@interface WinnerViewController : UIViewController {
    UIButton *btnStart;
    UILabel *lblCountdown;
    UIImageView *photoView;
    NSTimer *timer;
    BOOL _fixedResults;
    NSManagedObjectID *_lastId;
    UIActivityIndicatorView *loading;
    dispatch_semaphore_t _semaphore;
}

@property (strong, nonatomic) NSArray *people;

@end
