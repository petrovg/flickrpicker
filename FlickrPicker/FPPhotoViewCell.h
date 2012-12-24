//
//  PhotoViewCell.h
//  FlickrPicker
//
//  Created by George Petrov on 03/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

// An inamge selection button with a reference to a flickr
// photo dataset so that when it sends a message to it's
// handler it can get the photo details

@interface FPImageSelectionButton : UIButton

@property (nonatomic, weak) NSDictionary *photo;

@end


// The cell of the photos view table - containing a horizontal
// array of images for selection, overlayed with buttons for
// selecting the images, because UIImageView does not register
// touch-up event correctly

@interface FPPhotoViewCell : UITableViewCell

@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *buttons;

@end
