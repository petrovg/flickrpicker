# FlickrPicker

FlickrPicker is a UIImagePickerController-like class that allow you to select images from Flickr.

## Description

FlickrPicker is used the way you would use a UIImagePickerController. You present it modally and when it finishes it calls the approopriate method of:

    - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
    - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;


# Getting started

* Add the FlickrPicker project to your project
* Create a callback URL so that your app can be notified after user grants permissions
* Add Security.framework to Link binary with libraries in the Build phases


# TO DO

* Replace activity indicators with a single one
* Cache should survive dismissal to some extent
* When removing it must pop to the root controller, but without the doggy flickering views
