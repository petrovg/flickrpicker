//
//  FPPhotosViewController.m
//  FlickrPicker
//
//  Created by George Petrov on 02/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FPPhotosViewController.h"
#import "FlickrPicker.h"
#import "FPPhotoViewCell.h"

@interface FPPhotosViewController ()

@property (strong, nonatomic) NSMutableDictionary *thumbsCache;

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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[FlickrPicker sharedFlickrPicker] getPhotos:[self.photoset valueForKey:@"id"] completion:^(NSArray *photos){
        self.model.photos = photos;
        self.thumbsCache = [[NSMutableDictionary alloc] initWithCapacity:photos.count];
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    FPPhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (int photoPosition = 0; photoPosition < 4; photoPosition++)
    {
        int photoIndex = indexPath.row * 4 + photoPosition;
        if (photoIndex < self.model.photos.count)
        {
            NSDictionary *photo = [self.model.photos objectAtIndex:photoIndex];

            
            // Clear the image
            UIImageView *imageView = [cell.images objectAtIndex:photoPosition];
            [imageView setBackgroundColor:[UIColor lightGrayColor]];
            [imageView setImage:nil];

            // Get photos and update the image on a different queue
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
                NSURL *photoURL = [[FlickrPicker sharedFlickrPicker] getURLForPhoto:(NSDictionary *)photo];
                UIImage *image = [self.thumbsCache objectForKey:photoURL];
                if (!image)
                {
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
                    [self.thumbsCache setObject:image forKey:photoURL];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[((FPPhotoViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).images objectAtIndex:photoPosition] setImage:image];
                });
            });

            // Configure the button
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
