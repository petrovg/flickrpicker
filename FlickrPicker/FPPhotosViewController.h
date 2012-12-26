//
//  FPPhotosViewController.h
//  FlickrPicker
//
//  Created by George Petrov on 02/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPFlickrPickerModel.h"

@interface FPPhotosViewController : UITableViewController 

@property NSDictionary *photoset;
@property FPFlickrPickerModel *model;

@end
