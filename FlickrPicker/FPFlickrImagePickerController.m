//
//  FlickrPicker.m
//  FlickrPicker
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FPFlickrImagePickerController.h"
#import "FPPhotosetTableCell.h"
#import "FlickrPicker.h"

@interface FPFlickrImagePickerController ()

// The photosets, collated by their first letter
@property (strong, nonatomic) NSArray *collatedPhotosets;

@end

@implementation FPFlickrImagePickerController

void requestPhotosets(OFFlickrAPIRequest *request)
{
    // Initialise the context and request and ask for the photoset list
    NSLog(@"View is loading, getting pictures");
    [request setSessionInfo:@"Getting sets"];
    [request callAPIMethodWithGET:@"flickr.photosets.getList" arguments:nil];
}

-(void) viewDidLoad
{
    // If we are not authenticated, authenticate now
    OFFlickrAPIContext *context = [FlickrPicker sharedFlickrPicker].flickrContext;
    if (!context.OAuthToken.length)
    {
        OFFlickrAPIRequest *request = [FlickrPicker sharedFlickrPicker].flickrRequest;
        request.delegate = self;
        [request setSessionInfo:@"kFetchRequestTokenStep"];
        [request fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:@"flickrpicker://auth"]];
    }
    else {
        NSLog(@"Already authenticated");
    }
    
    // Init the table view
    [self.tableView registerClass:[FPPhotosetTableCell class] forCellReuseIdentifier:@"PhotosetCell"];
    
}

#pragma mark OFFlickrAPIRequestDelegate
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
    NSLog(@"Got token: %@ and secret: %@", inRequestToken, inSecret);
    [[[FlickrPicker sharedFlickrPicker] flickrContext] setOAuthToken:inRequestToken];
    [[[FlickrPicker sharedFlickrPicker] flickrContext] setOAuthTokenSecret:inSecret];
    NSURL *authURL = [[FlickrPicker sharedFlickrPicker].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrReadPermission];
    NSLog(@"Opening authURL %@", authURL);
    [[UIApplication sharedApplication] openURL:authURL];
}

-(void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"Error : %@", inError);
}

#pragma mark UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.collatedPhotosets.count;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.collatedPhotosets objectAtIndex:section] count];
}

NSArray* collatePhotosets(NSArray* rawPhotosets)
{
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:30];
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    for (int i = 0; i < collation.sectionIndexTitles.count; i++)
    {
        [sections addObject:[NSMutableArray arrayWithCapacity:(rawPhotosets.count / collation.sectionIndexTitles.count + 5)]];
    }
    for (NSDictionary *photoset in rawPhotosets)
    {
        NSInteger sectionIndex = [collation sectionForObject:photoset collationStringSelector:@selector(photosetName)];
        [[sections objectAtIndex:sectionIndex] addObject:photoset];
    }
    return [NSArray arrayWithArray:sections];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotosetCell"];
    NSArray *section = [self.collatedPhotosets objectAtIndex:indexPath.section];
    NSDictionary *photoset = [section objectAtIndex:indexPath.row];
    [cell.textLabel setText:[photoset valueForKeyPath:@"title._text"]];
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



@end
