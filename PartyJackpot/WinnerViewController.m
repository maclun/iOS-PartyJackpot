//
//  WinnerViewController.m
//  PartyJackpot
//
//  Created by Maciek on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WinnerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface WinnerViewController ()

@property (nonatomic, strong, readwrite) UILabel *winnerLabel;
@property (nonatomic, strong, readwrite) UIButton *btnMouseWinner;
@property (nonatomic, strong, readwrite) UIImage *mouse;

@end

@implementation WinnerViewController

@synthesize people;
@synthesize winnerLabel = _winnerLabel;
@synthesize btnMouseWinner = _btnMouseWinner;
@synthesize mouse = _mouse;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *log = [NSString stringWithFormat:@"Jackpot (%f)", self.navigationController.navigationBar.frame.size.height];
    NSLog(@"%@", log);
    CGRect btnFrame = CGRectMake(0, 0, 320, 480 - (self.navigationController.navigationBarHidden ? 0 : self.navigationController.navigationBar.frame.size.height));
    
    _mouse = [UIImage imageNamed:@"mouse.jpg"];
    
    btnStart = [[UIButton alloc] initWithFrame:btnFrame];
    [btnStart setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [btnStart setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [btnStart setTitle:@"Tap to start!" forState:UIControlStateNormal];
    [btnStart addTarget:self action:@selector(drawWinner) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnStart];

    _btnMouseWinner = [[UIButton alloc] initWithFrame:CGRectMake(0, btnFrame.size.height - 50, 320, 50)];
    _btnMouseWinner.backgroundColor = [UIColor clearColor];
    [_btnMouseWinner addTarget:self action:@selector(fixedResults) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_btnMouseWinner];

    lblCountdown = [[UILabel alloc] initWithFrame:btnFrame];
    lblCountdown.textAlignment = UITextAlignmentCenter;
    lblCountdown.font = [UIFont fontWithName:@"Arial" size:400];
    lblCountdown.backgroundColor = [UIColor clearColor];
    lblCountdown.textColor = [UIColor whiteColor];
    
    [self.view addSubview:lblCountdown];
    
    photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 436)];
    [self.view addSubview:photoView];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolbar)];
    photoView.userInteractionEnabled = YES;    
    [photoView addGestureRecognizer:tgr];
    
    loading = [[UIActivityIndicatorView alloc] initWithFrame:btnFrame];
    [self.view addSubview:loading];
    
    self.winnerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 60)];
    _winnerLabel.backgroundColor = [UIColor clearColor];
    _winnerLabel.textColor = [UIColor yellowColor];
    _winnerLabel.font = [UIFont systemFontOfSize:40];
    _winnerLabel.layer.shadowOpacity = 1.0;   
    _winnerLabel.layer.shadowRadius = 3.0;
    _winnerLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _winnerLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    _winnerLabel.transform = CGAffineTransformMakeRotation( -M_PI/8 );
    _winnerLabel.hidden = YES;
    _winnerLabel.alpha = 0;
    _winnerLabel.text = @"Winner!";
    
    [self.view addSubview:_winnerLabel];
}

- (void) showToolbar
{
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    
}

- (void)viewWillAppear:(BOOL)animated
{
//    if (nil != _semaphore) {
//        dispatch_semaphore_signal(_semaphore);
//    }
    _semaphore = dispatch_semaphore_create(0);
    self.title = @"";
    self.view.backgroundColor = [UIColor blackColor];
    photoView.hidden = YES;
    lblCountdown.hidden = YES;
    btnStart.alpha = 0.0;
    btnStart.hidden = NO;
    _winnerLabel.hidden = YES;
    _winnerLabel.alpha = 0;
    photoView.userInteractionEnabled = YES;
    _btnMouseWinner.userInteractionEnabled = YES;
    btnStart.userInteractionEnabled = YES;
    
    CGRect btnFrame = CGRectMake(0, 0, 320, 480 - (self.navigationController.navigationBarHidden ? 0 : self.navigationController.navigationBar.frame.size.height));
    
    btnStart.frame = btnFrame;
    _btnMouseWinner.frame = CGRectMake(0, btnFrame.size.height - 50, 320, 50);
    
    [UIView animateWithDuration:0.5 animations:^{
        btnStart.alpha = 1.0;
    }];
    
    
}

- (void)viewWillDisappear:(BOOL)animated{
    _winnerLabel.hidden = YES;
    _winnerLabel.alpha = 0;
}

- (void) drawWinner
{
    _fixedResults = NO;
    _btnMouseWinner.userInteractionEnabled = NO;
    btnStart.userInteractionEnabled = NO;
    photoView.userInteractionEnabled = NO;
    [UIView animateWithDuration:1.0 animations:^{
        btnStart.alpha = 0.0;
    } completion:^(BOOL finished) {
        lblCountdown.alpha = 0.0;
        lblCountdown.hidden = NO;
        
        [self drawWinner2:9];
    }];
}

- (void)fixedResults{
    _fixedResults = YES;
    _btnMouseWinner.userInteractionEnabled = NO;
    btnStart.userInteractionEnabled = NO;
    photoView.userInteractionEnabled = NO;
    [UIView animateWithDuration:1.0 animations:^{
        btnStart.alpha = 0.0;
    } completion:^(BOOL finished) {
        lblCountdown.alpha = 0.0;
        lblCountdown.hidden = NO;
        
        [self drawWinner2:9];
    }];
}

- (void) drawWinner2:(NSInteger) count
{
    float fadeInTime = 0.2;
    float fadeOutTime = 0.0;
    
    lblCountdown.text = [NSString stringWithFormat:@"%d", count];
    
    [UIView animateWithDuration:fadeInTime animations:^{
        lblCountdown.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:fadeOutTime animations:^{
            lblCountdown.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (count == 1) {
                [self performDrawing];
            } else {
                [self drawWinner2:(count-1)];
            }
        }];
    }];
}

- (void) performDrawing
{
    if (self.people.count > 0) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        
        int total = 200;
        
        for (int i = 0; i < total; i++) {
            [queue addOperationWithBlock:^{
                double delayInSeconds = 0.1 * MAX( 2, i - ( total - 20 ) ) / 2;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^(void){
                    if (_fixedResults && total -1 == i) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            self.title = @"Mr. Mouse";
                            photoView.hidden = NO;
                            photoView.image = _mouse;
                        });
                        dispatch_semaphore_signal(_semaphore);
                    }
                    else{
                        [self showRandomPhoto];
                    }
                    if (total -1 == i ) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.view.backgroundColor = [UIColor yellowColor];
                            _winnerLabel.alpha = 0;
                            _winnerLabel.hidden = NO;
                            [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionRepeat |
                             UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseInOut animations:^{
                                _winnerLabel.alpha = 1;
                            } completion:^(BOOL finished) {
                                
                            }];
                        });
                    }
                });
                dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
                }];
        }
    } else {
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void) showRandomPhoto
{
    NSInteger index = self.people.count == 1 ? 0 : MAX(rand() % self.people.count, 0);
    Person *winner = [self.people objectAtIndex:index];
    
    if (_lastId == winner.objectID && self.people.count > 1) {
        [self showRandomPhoto];
        return;
    }
    
    _lastId = winner.objectID;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.title = winner.name;
        photoView.hidden = NO;
        photoView.image = [winner getImageFromData];
    });
    dispatch_semaphore_signal(_semaphore);
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
