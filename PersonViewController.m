//
//  PersonViewController.m
//  PartyJackpot
//
//  Created by Maciek on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonViewController.h"
#import "MainViewController.h"

@interface PersonViewController ()

@end

@implementation PersonViewController

@synthesize person;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        [self.view addSubview:_imageView];
    }
    
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 330, 320, 150)];
        _nameLabel.textAlignment = UITextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:30.0];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_nameLabel];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    UIImage *photo = [person getImageFromData];
    _imageView.image = photo;
    
    if ([MainViewController isImagePortrait:photo]) {
        // portrait mode
        _imageView.frame = CGRectMake(40, 10, 240, 320);
    } else {
        // landscape mode
        _imageView.frame = CGRectMake(0, 10, 320, 240);        
    }
    
    _nameLabel.text = person.name;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
