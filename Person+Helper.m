//
//  Person+Helper.m
//  PartyJackpot
//
//  Created by Maciek on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person+Helper.h"

@implementation Person (Helper)

- (UIImage *)getImageFromData {
    if (self.photo && self.photoImage == nil) {
        self.photoImage = [UIImage imageWithData:self.photo];
    }
    return self.photoImage;
}

- (void)setImage:(UIImage *)image {
    self.photo = UIImageJPEGRepresentation(image, 0.7);
}

@end
