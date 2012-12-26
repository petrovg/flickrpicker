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

@property NSMutableDictionary *thumbnailCache;
@property NSArray *photos;
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
    self.thumbnailCache = [NSMutableDictionary dictionaryWithCapacity:self.photos.count];
    [self.tableView registerClass:[FPPhotoViewCell class] forCellReuseIdentifier:@"PhotoCell"];
    
    // Add a cancel button
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:[FlickrPicker sharedFlickrPicker] action:@selector(cancel)];
    [[self navigationItem] setRightBarButtonItem:cancelButtonItem];

    // Hide the separator
    [self.tableView setSeparatorColor:self.tableView.backgroundColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // Take up the whole screen
    [self setWantsFullScreenLayout:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View will appear. There are %d cache entries", self.thumbnailCache.count);
    [super viewWillAppear:animated];
    [[FlickrPicker sharedFlickrPicker] getPhotos:[self.photoset valueForKey:@"id"] completion:^(NSArray *photos){
        NSLog(@"Got %d photos", photos.count);
        self.photos = photos;
        [self.tableView reloadData];
    }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

-(void) viewDidDisappear:(BOOL)animated
{
    self.photos = nil;
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
    NSLog(@"Selected image is %@", senderButton.photo);
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
    NSInteger count = self.photos.count / 4 + 1;
    //if (self.photos.count % 4) count++;
    return count;
}

void setUpPhoto(NSDictionary *photo, UIImageView *photoHolder, NSMutableDictionary* cache) {
    [photoHolder setImage:nil];
    static NSString *FPFlickrSquareSize = @"q";
    NSURL *photoURL = [[[FlickrPicker sharedFlickrPicker] flickrContext]
                       photoSourceURLFromDictionary:photo size:FPFlickrSquareSize];
    UIImage *cachedThumb = [cache objectForKey:photoURL];
    
    if (cachedThumb)
    {
        [photoHolder setImage:cachedThumb];
    }
    
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            //UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            //activityIndicator.frame = photoHolder.bounds;
            //activityIndicator.hidesWhenStopped = YES;
            //[photoHolder addSubview:activityIndicator];
            //[activityIndicator startAnimating];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
            [photoHolder setImage:image];
            //[activityIndicator stopAnimating];
            //[activityIndicator removeFromSuperview];
            [cache setObject:image forKey:photoURL];
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
        if (photoIndex < self.photos.count)
        {
            [[cell.images objectAtIndex:photoPosition] setBackgroundColor:[UIColor lightGrayColor]];
            NSDictionary *photo = [self.photos objectAtIndex:photoIndex];
            setUpPhoto(photo, [cell.images objectAtIndex:photoPosition], self.thumbnailCache);
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
