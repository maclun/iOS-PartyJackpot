//
//  PersonViewController.h
//  PartyJackpot
//
//  Created by Maciek on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person+Helper.h"

@interface PersonViewController : UIViewController {
    UIImageView *_imageView;
    UILabel *_nameLabel;
}

@property (strong, nonatomic) Person *person;

@end
