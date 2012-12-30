//
//  UINavigationController+UIImagePickerController.m
//  FlickrPicker
//
//  Created by George Petrov on 30/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "UINavigationController+UIImagePickerController.h"

@implementation UINavigationController (UIImagePickerController)

-(UIImagePickerControllerSourceType) sourceType
{
    return UIImagePickerControllerSourceTypePhotoLibrary;
}

@end
