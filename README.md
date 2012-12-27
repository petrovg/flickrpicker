# FlickrPicker

FlickrPicker is a UIImagePickerController-like class that allow you to select images from Flickr.

## Description

FlickrPicker is used the way you would use a UIImagePickerController. You present it modally and when it finishes it calls the approopriate method of:

    - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
    - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;


## Getting started

* Add the FlickrPicker project to your project
* Create a callback URL so that your app can be notified after user grants permissions
* Add Security.framework to Link binary with libraries in the Build phases


## TO DO

* Test in a popover on iPad
* Replace activity indicators with a single one
* Make it only support portrait orientation
