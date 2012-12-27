//
//  FPPhotosViewController.m
//  FlickrPicker
//
//  Created by George Petrov on 02/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FPPhotosViewController.h"
#import "ObjectiveFlickr.h"
#import "FlickrPicker.h"
#import "FPPhotoViewCell.h"

@interface FPPhotosViewController ()


@end

@implementation FPPhotosViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[FPPhotoViewCell class] forCellReuseIdentifier:@"PhotoCell"];
    
    // Add a cancel button
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:[FlickrPicker sharedFlickrPicker] action:@selector(cancel)];
    [[self navigationItem] setRightBarButtonItem:cancelButtonItem];

    // Hide the separator
    [self.tableView setSeparatorColor:self.tableView.backgroundColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // Take up the whole screen
    [self setWantsFullScreenLayout:YES];
    
    // A footer to make the bottom end look nice
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 4)]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[FlickrPicker sharedFlickrPicker] getPhotos:[self.photoset valueForKey:@"id"] completion:^(NSArray *photos){
        self.model.photos = photos;
        [self.tableView reloadData];
    }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

-(void) viewDidDisappear:(BOOL)animated
{
    self.model.photos = nil;
    [self.tableView reloadData];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) pickedPhoto:(id)sender
{
    FPImageSelectionButton *senderButton = (FPImageSelectionButton*) sender;
    [[FlickrPicker sharedFlickrPicker] imagePicked:senderButton.photo];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.model.photos.count / 4 + 1;
    if (self.model.photos.count % 4 == 0) count--;
    return count;
}

-(void) setUpPhoto:(NSDictionary *)photo holder:(UIImageView *)photoHolder
{
    [photoHolder setImage:nil];
    static NSString *FPFlickrSquareSize = @"q";
    NSURL *photoURL = [[[FlickrPicker sharedFlickrPicker] flickrContext]
                       photoSourceURLFromDictionary:photo size:FPFlickrSquareSize];
    UIImage *cachedThumb = [self.model.thumbnailCache objectForKey:photoURL];
    
    if (cachedThumb)
    {
        [photoHolder setImage:cachedThumb];
    }
    
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
            [photoHolder setImage:image];
            [self.model.thumbnailCache setObject:image forKey:photoURL];
        });
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    FPPhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (int photoPosition = 0; photoPosition < 4; photoPosition++)
    {
        int photoIndex = indexPath.row * 4 + photoPosition;
        if (photoIndex < self.model.photos.count)
        {
            [[cell.images objectAtIndex:photoPosition] setBackgroundColor:[UIColor lightGrayColor]];
            NSDictionary *photo = [self.model.photos objectAtIndex:photoIndex];
            [self setUpPhoto:photo holder:[cell.images objectAtIndex:photoPosition]];
            FPImageSelectionButton *imageSelectionButton = (FPImageSelectionButton*)[cell.buttons objectAtIndex:photoPosition];
            imageSelectionButton.photo = photo;
            [imageSelectionButton addTarget:self action:@selector(pickedPhoto:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [[cell.images objectAtIndex:photoPosition] setBackgroundColor:[UIColor clearColor]];
            [[cell.images objectAtIndex:photoPosition] setImage:nil];
        }
    }

    return cell;
}


@end
