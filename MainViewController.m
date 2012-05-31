    //
//  MainViewController.m
//  PartyJackpot
//
//  Created by Maciek on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "Person+Helper.h"
#import "UIImage+Resize.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize context = _context;
@synthesize people = _people;
@synthesize initialized;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.alpha = 0.0;
    
    _entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:_context];
    _semaphoreRefresh = dispatch_semaphore_create(1);
    _semaphoreLoadCellImage = dispatch_semaphore_create(1);
    
    self.title = @"Jackpot";
    UIImage *image = [UIImage imageNamed:@"jackpot.jpg"];
    UIImageView *photo = [[UIImageView alloc] initWithImage:image];
    CGRect photoFrame = self.tableView.frame;
    photo.frame = photoFrame;
    photo.alpha = 0.3;
    self.tableView.backgroundView = photo;
    
    self.tableView.rowHeight = 84;

    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Player" style:UIBarButtonItemStylePlain target:self action:@selector(openCamera)];
    
    UIBarButtonItem *drawWinnerButton = [[UIBarButtonItem alloc] initWithTitle:@"Draw Winner" style:UIBarButtonItemStylePlain target:self action:@selector(drawWinner)];
    
    self.navigationItem.leftBarButtonItem = takePhotoButton;
    self.navigationItem.rightBarButtonItem = drawWinnerButton;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect activityIndicatorFrame = self.tableView.frame;
    [_activityIndicator setFrame:activityIndicatorFrame];
    [self.view addSubview:_activityIndicator];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.view.alpha = 1.0;
    }];
    
    if (initialized == NO) {
        initialized = YES;
        [self refreshTable];
    }
}

- (void) startActivityIndicator
{
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSLog(@"Activity indicator started");
}

- (void) stopActivityIndicator
{
    [_activityIndicator stopAnimating];
    self.view.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    NSLog(@"Activity indicator stopped");    
}

- (void) refreshTable 
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^{
        dispatch_semaphore_wait(_semaphoreRefresh, DISPATCH_TIME_FOREVER);
        
        [self performSelectorOnMainThread:@selector(startActivityIndicator) withObject:nil waitUntilDone:NO];
        
        self.people = [self fetchAllPeople];
        
        [self performSelectorOnMainThread:@selector(updateTitle) withObject:nil waitUntilDone:YES];

        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        dispatch_semaphore_signal(_semaphoreRefresh);
    });
}

- (void) updateTitle 
{
    NSString *title = [NSString stringWithFormat:@"Jackpot (%d)", self.people.count];
    self.title = title;
}

- (NSArray*)fetchAllPeople 
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	
	NSArray *results = [_context executeFetchRequest:fetchRequest error:&error];
	
    results = [results sortedArrayUsingComparator:^(id a, id b){
        NSString *nameA = [(Person*) a name];
        NSString *nameB = [(Person*) b name];
        return [nameA caseInsensitiveCompare:nameB];
    }];
    
    return results;
}

- (void) openCamera 
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        //[self.navigationController pushViewController:imagePicker animated:YES];
        [self presentModalViewController:imagePicker animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    [self dismissModalViewControllerAnimated:YES];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*) kUTTypeImage]) {
        _takenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        _takenImage = [UIImage imageWithCGImage:_takenImage.CGImage scale:0.25 orientation:_takenImage.imageOrientation];
        
        UIAlertView *detailAlertView = [[UIAlertView alloc] initWithTitle:@"Who is it?"
                                                                  message:@"Enter the name of the photographed person"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"Ok", nil];
        
        detailAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        detailAlertView.tag = 1;
        [detailAlertView textFieldAtIndex:0].placeholder = @"Name";
        [detailAlertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
        [detailAlertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
        [self startActivityIndicator];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^{
            [self savePerson:[[alertView textFieldAtIndex:0].text capitalizedString] WithImage:_takenImage];
            [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        });
	}
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) drawWinner {
    if (_winnerView == nil) {
        _winnerView = [[WinnerViewController alloc] init];
    }
    
    _winnerView.people = _people;
    [self.navigationController pushViewController:_winnerView animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _people.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
        UIImageView *imageViewPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(13, 4, 57, 76)];
        imageViewPortrait.tag = 1;
        [cell.contentView addSubview:imageViewPortrait];

        UIImageView *imageViewLandscape = [[UIImageView alloc] initWithFrame:CGRectMake(4, 13, 76, 57)];
        imageViewLandscape.tag = 2;
        [cell.contentView addSubview:imageViewLandscape];
        
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(4, 4, 76, 76)];
        loadingView.tag = 3;
        [cell.contentView addSubview:loadingView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 22, 220, 40)];
        nameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLabel];
        nameLabel.tag = 10;
        nameLabel.font = [UIFont systemFontOfSize:22.0];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Person *person = [self.people objectAtIndex:indexPath.row];
    
    UILabel *labelView = (UILabel*) [cell viewWithTag:10];
    labelView.text = person.name;

    UIImageView *imageViewPortrait = (UIImageView*) [cell viewWithTag:1];
    UIImageView *imageViewLandscape = (UIImageView*) [cell viewWithTag:2];
    
    UIActivityIndicatorView *loadingView = (UIActivityIndicatorView*) [cell viewWithTag:3];
    
    imageViewPortrait.hidden = YES;
    imageViewLandscape.hidden = YES;

	UIImage *photo = [person getImageFromData];
	UIImageView *imageView;
	if ([MainViewController isImagePortrait:photo]) {
		imageView = imageViewPortrait;
	} else {
		imageView = imageViewLandscape;
	}
	imageView.image = photo;
	imageView.hidden = NO;
	
//    [loadingView startAnimating];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^{
//        dispatch_semaphore_wait(_semaphoreLoadCellImage, DISPATCH_TIME_FOREVER);
//        
//        UIImage *photo = [person getImageFromData];
//        UIImageView *imageView;
//        if ([MainViewController isImagePortrait:photo]) {
//            imageView = imageViewPortrait;
//        } else {
//            imageView = imageViewLandscape;
//        }
//        
//        imageView.image = photo;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            imageView.alpha = 0.0;
//            imageView.hidden = NO;
//            [UIView animateWithDuration:0.5 animations:^{
//                imageView.alpha = 1.0;
//                loadingView.alpha = 0.0;
//            } completion:^(BOOL finished) {
//                [loadingView stopAnimating];
//                loadingView.alpha = 1.0;
//            }];
//        });
//        dispatch_semaphore_signal(_semaphoreLoadCellImage);
//    });
        
    return cell;
}

+ (BOOL) isImagePortrait:(UIImage*) image
{
    if (image.size.width < image.size.height) {
        // portrait mode
        return YES;
    } else {
        // landscape mode
        return NO;
    }
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSLog(@"Deleting...");

        // Delete the managed object at the given index path.
        NSManagedObject *person = [self.people objectAtIndex:indexPath.row];
        [self.context deleteObject:person];
        
        // Commit the change.
        NSError *error = nil;
        if (![self.context save:&error]) {
            // Handle the error.
        } else {
            // Update the array and table view.
            NSMutableArray *updatedPeople = [NSMutableArray arrayWithArray:self.people];
            [updatedPeople removeObjectAtIndex:indexPath.row];
            
            self.people = updatedPeople;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            
            [self updateTitle];
        }
        
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *person = [self.people objectAtIndex:indexPath.row];
    
    if (_personView == nil) {
        _personView = [[PersonViewController alloc] init];
    }
    
    _personView.person = person;
    
    [self.navigationController pushViewController:_personView animated:YES];
}

- (void) savePerson:(NSString*)name WithImage:(UIImage*)image { 
    Person *person = (Person*) [[NSManagedObject alloc] initWithEntity:_entity insertIntoManagedObjectContext:_context];
	
    person.name = name;
    [person setImage:[image resizedImage:CGSizeMake(640, 854) interpolationQuality:kCGInterpolationHigh]];
    
	[self performSelectorOnMainThread:@selector(saveContext) withObject:nil waitUntilDone:YES];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _context;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

@end
