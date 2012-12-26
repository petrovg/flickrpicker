//
//  FPFlickrPickerModel.h
//  FlickrPicker
//
//  Created by George Petrov on 26/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPFlickrPickerModel : NSObject

@property (strong, nonatomic) NSArray *collatedPhotosets;
@property NSMutableDictionary *thumbnailCache;
@property NSArray *photos;

@end
