//
//  People.m
//  PartyJackpot
//
//  Created by Maciek on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "People.h"

@implementation People

static People *instance = nil;
static dispatch_once_t onceToken = 0;

+ (People*) sharedInstance {
    dispatch_once(&onceToken, ^{
        instance = [[People alloc] init];
    });
    return instance;
}
@end
