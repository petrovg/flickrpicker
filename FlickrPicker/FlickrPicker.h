//
//  FlickrPicker.h
//  FlickrPicker
//
//  Created by George Petrov on 11/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveFlickr.h"

@interface FlickrPicker : NSObject <OFFlickrAPIRequestDelegate>

@property (nonatomic, strong, readonly) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong, readonly) OFFlickrAPIRequest *flickrRequest;

+(FlickrPicker*)sharedFlickrPicker;

@end
