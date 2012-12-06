//
//  ViewController.m
//  PickAFlick
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "PAFViewController.h"
#import "FPFlickrImagePickerController.h"

@interface PAFViewController ()

@end

@implementation PAFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickImage:(id)sender {
    FPFlickrImagePickerController *picker = [[FPFlickrImagePickerController alloc] init];
    [self presentViewController:picker animated:YES completion:nil];
}

@end
