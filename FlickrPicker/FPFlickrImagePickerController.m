//
//  FlickrPicker.m
//  FlickrPicker
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FPFlickrImagePickerController.h"
#import "ObjectiveFlickr.h"

@interface FPFlickrImagePickerController ()

@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;
@property (strong, nonatomic) OFFlickrAPIRequest *flickrRequest;

// The photosets, collated by their first letter
@property (strong, nonatomic) NSArray *collatedPhotosets;

@end

@implementation FPFlickrImagePickerController

-(void) viewDidLoad
{
    // Initialise the context and request and ask for the photoset list
    NSLog(@"View is loading");
}

@end
