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
@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong) void (^blockToRunWhenAuthorized)(void);

+(FlickrPicker*)sharedFlickrPicker;
-(void) authorize;

@end
