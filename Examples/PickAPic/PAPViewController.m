//
//  ViewController.m
//  PickAFlick
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "PAPViewController.h"
#import "FlickrPicker.h"


@interface PAPViewController ()

@end

@implementation PAPViewController

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
    UIViewController *picker = [[FlickrPicker sharedFlickrPicker] flickrImagePickerControllerWithDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)pickFromStandard:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
}

// Clears the stored authorization data
- (IBAction)deauthorize:(id)sender {
    [[FlickrPicker sharedFlickrPicker] clearAuthData];
}

#pragma mark UIImagePickerControlleDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Selected image info from %@ is %@", picker, info);
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.photoView setImage:selectedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
