//
//  FlickrPicker.m
//  FlickrPicker
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FPPhotosetsController.h"
#import "FPPhotosetTableCell.h"
#import "FlickrPicker.h"
#import "NSDictionary+Photoset.h"
#import "FPPhotosViewController.h"

@interface FPPhotosetsController ()
{
    FPPhotosViewController *photosViewController;
}

// The photosets, collated by their first letter
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic, readonly) FPPhotosViewController *photosViewController;

@end

@implementation FPPhotosetsController

-(void) viewDidLoad
{
    // Try get the auth token
    //[[FlickrPicker sharedFlickrPicker] retrieveSavedAuthTokenAndSecret];
    
    // If we are not authorized, authorize now
    if (![[FlickrPicker sharedFlickrPicker] isAuthorized])
    {
        // Run this when authorized
        [[FlickrPicker sharedFlickrPicker] setBlockToRunWhenAuthorized:^{
            NSLog(@"OK, getting photosets and refresh the table view %@ now", self.tableView);
            [[FlickrPicker sharedFlickrPicker] getPhotosets:^(NSArray *collatedPhotosets){
                // This will run when the photosets are here
                [self.tableView reloadData];
                [self.activityIndicator stopAnimating];
                NSLog(@"Stopped animating?... Hmmmm...");
                }];
            }];
        [[FlickrPicker sharedFlickrPicker] authorize];
    }
    else {
        NSLog(@"Already authorized");
    }
    
    // Init the table view
    [self.tableView registerClass:[FPPhotosetTableCell class] forCellReuseIdentifier:@"PhotosetCell"];
    
    // Show activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = self.view.bounds;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    
    // Add a cancel button
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:[FlickrPicker sharedFlickrPicker] action:@selector(cancel)];
    [[self navigationItem] setRightBarButtonItem:cancelButtonItem];
    
    // Fill up the screen the way the native image picker does
    [self setWantsFullScreenLayout:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

#pragma mark UITableViewDelegate

-(void) tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Chosen photoset at index path: %@", indexPath);
    FPPhotosViewController *photosViewController = self.photosViewController;
    photosViewController.model = self.model;
    photosViewController.photoset = [[self.model.collatedPhotosets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:photosViewController animated:YES];
}




#pragma mark UITableViewDataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.model.collatedPhotosets.count;
    NSLog(@"(1) Returning count %d", count);
    return count;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self.model.collatedPhotosets objectAtIndex:section] count];
    NSLog(@"(2) Returning count %d for section %d", count, section);
    return count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"(3) About to make a cell for index path %@", indexPath);
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotosetCell"];
    NSArray *section = [self.model.collatedPhotosets objectAtIndex:indexPath.section];
    NSDictionary *photoset = [section objectAtIndex:indexPath.row];
    [cell.textLabel setText:[photoset valueForKeyPath:@"title._text"]];
    NSLog(@"(4) Made a cell: %@", cell);
    return cell;
}

-(NSArray*) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

-(NSInteger) tableView:tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    return section;
}

#pragma mark The FPPhotosViewController
// This is the FPPhotosViewController that shows the photos once a photoset is chosen
-(FPPhotosViewController *) photosViewController
{
    if (!photosViewController)
        photosViewController = [[FPPhotosViewController alloc] init];
    
    return photosViewController;
}



@end
