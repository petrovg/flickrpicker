//
//  FPFlickrImagePickerController.m
//  FlickrPicker
//
//  Created by George Petrov on 15/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FPFlickrImagePickerController.h"

@interface FPFlickrImagePickerController ()

@end

@implementation FPFlickrImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
