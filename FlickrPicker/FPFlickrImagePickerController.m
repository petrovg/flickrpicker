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
#import "NSDictionary+Photoset.h"

@interface FPFlickrImagePickerController ()

// The photosets, collated by their first letter
@property (strong, nonatomic) NSArray *collatedPhotosets;

@end

@implementation FPFlickrImagePickerController

-(void) viewDidLoad
{
    // If we are not authorized, authorize now
    OFFlickrAPIContext *context = [FlickrPicker sharedFlickrPicker].flickrContext;
    if (!context.OAuthToken.length)
    {
        // Run this when authorized
        [[FlickrPicker sharedFlickrPicker] setBlockToRunWhenAuthorized:^{
            NSLog(@"OK, getting photosets and refresh the table view %@ now", self.tableView);
            [[FlickrPicker sharedFlickrPicker] getPhotosets:^(NSArray *photosets) {
                // This will run when the photosets are here
                self.collatedPhotosets = collatePhotosets(photosets);
                NSLog(@"Collated photosets are %@", self.collatedPhotosets);
                [self.tableView reloadData];
                }];
            }];
        [[FlickrPicker sharedFlickrPicker] authorize];
    }
    else {
        NSLog(@"Already authorized");
    }
    
    // Init the table view
    [self.tableView registerClass:[FPPhotosetTableCell class] forCellReuseIdentifier:@"PhotosetCell"];
    
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


#pragma mark UITableViewDataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.collatedPhotosets.count;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.collatedPhotosets objectAtIndex:section] count];
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
