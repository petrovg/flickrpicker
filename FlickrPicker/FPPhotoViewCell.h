//
//  PhotoViewCell.h
//  FlickrPicker
//
//  Created by George Petrov on 03/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FPImageSelectionButton : UIButton

@property (nonatomic, weak) NSDictionary *photo;

@end



@interface FPPhotoViewCell : UITableViewCell

@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *buttons;

@end
