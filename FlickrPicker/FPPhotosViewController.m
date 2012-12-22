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
    [[FlickrPicker sharedFlickrPicker] getPhotos:[self.photoset valueForKey:@"id"] completion:^(NSArray *photos){
        NSLog(@"Got %d photos", photos.count);
        self.photos = photos;
        [self.tableView reloadData];
    }];
    [self.tableView registerClass:[FPPhotoViewCell class] forCellReuseIdentifier:@"PhotoCell"];
    
    // Add a cancel button
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:[FlickrPicker sharedFlickrPicker] action:@selector(cancel)];
    [[self navigationItem] setRightBarButtonItem:cancelButtonItem];

}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View will appear. Cache is %@", self.thumbnailCache);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) pickedPhoto:(id)sender
{
    FPFlickrImagePickerController *imagePicker = [[FlickrPicker sharedFlickrPicker] flickrImagePickerController];
    id<UIImagePickerControllerDelegate> pickerDelegate = imagePicker.delegate;
    FPImageSelectionButton *senderButton = (FPImageSelectionButton*) sender;
    NSLog(@"Selected image is %@", senderButton.photo);
    NSURL *selectedPhotoURL = [[[FlickrPicker sharedFlickrPicker] flickrContext] photoSourceURLFromDictionary:senderButton.photo size:OFFlickrMediumSize];
    UIImage *selectedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:selectedPhotoURL]];
    NSDictionary *imageInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"public.image", UIImagePickerControllerMediaType,
                               selectedImage, UIImagePickerControllerOriginalImage,
                               selectedPhotoURL, UIImagePickerControllerReferenceURL ,nil];
    [pickerDelegate imagePickerController:imagePicker didFinishPickingMediaWithInfo:imageInfo];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.photos.count / 4;
    if (self.photos.count % 4) count++;
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
        NSLog(@"<== No cached image for url %@. Downloading...", photoURL);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.frame = photoHolder.bounds;
            activityIndicator.hidesWhenStopped = YES;
            [photoHolder addSubview:activityIndicator];
            [activityIndicator startAnimating];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
            [photoHolder setImage:image];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
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
            NSDictionary *photo = [self.photos objectAtIndex:photoIndex];
            setUpPhoto(photo, [cell.images objectAtIndex:photoPosition], self.thumbnailCache);
            FPImageSelectionButton *imageSelectionButton = (FPImageSelectionButton*)[cell.buttons objectAtIndex:photoPosition];
            imageSelectionButton.photo = photo;
            [imageSelectionButton addTarget:self action:@selector(pickedPhoto:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [[cell.images objectAtIndex:photoPosition] setImage:nil];
        }
    }

    return cell;
}


@end
