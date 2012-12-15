//
//  ViewController.m
//  PickAFlick
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "PAFViewController.h"
#import "FPPhotosetsController.h"

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
    FPPhotosetsController *picker = [[FPPhotosetsController alloc] init];
    [self presentViewController:picker animated:YES completion:nil];
}

@end
