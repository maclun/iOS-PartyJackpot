//
//  MainViewController.h
//  PartyJackpot
//
//  Created by Maciek on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person+Helper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PersonViewController.h"
#import "WinnerViewController.h"

@interface MainViewController : UITableViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSEntityDescription *_entity;
    UIImage *_takenImage;
    UIActivityIndicatorView *_activityIndicator;
    dispatch_semaphore_t _semaphoreRefresh, _semaphoreLoadCellImage;
    PersonViewController *_personView;
    WinnerViewController *_winnerView;
}

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSArray *people;
@property (readwrite) BOOL initialized;

+ (BOOL) isImagePortrait:(UIImage*) image;

@end
