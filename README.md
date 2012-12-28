# FlickrPicker

FlickrPicker is a UIImagePickerController-like class that allow you to select images from Flickr.

FlickrPicker is used the same way as a UIImagePickerController - it is created, assigned a delegate, presented modally and when it finishes it calls the appropriate method of UIImagePickerDelegate.


## Using FlickrPicker

### Add the FlickrPicker project to your project
### Create a callback URL so that your app can be notified after user authorizes it
### Add Security.framework
### Implement the openURL method in your AppDelegate

This is necassary, so that Safari can re-launch your app once the user has authorized access to their Flickr account.

    -(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSStrin *)sourceApplication annotation:(id)annotation
    {
        NSLog(@"Opening url %@", url);
        NSString *token = nil;
        NSString *verifier = nil;
        BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:@"flickrpicker://auth"], &token, &verifier);

        if (!result) {
            NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
            return NO;
        }

        OFFlickrAPIRequest *request = [FlickrPicker sharedFlickrPicker].flickrRequest;
        request.sessionInfo = @"kGetAccessTokenStep";
        [request fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];

        return YES;
    }

### Get and present a FlickrPicker view controller:

        UIViewController *picker = [[FlickrPicker sharedFlickrPicker] flickrImagePickerControllerWithDelegate:self];
        NSLog(@"Using picker %@", picker);
        [self presentViewController:picker animated:YES completion:nil];


### Dismiss the controller when an image is selected or selection is cancelled

    -(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
    {
        UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        // Do womething with the image
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    -(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }


## License

FlickrPicker is released under the simplified BSD License. The text of the license can be found in license.txt

FlickrPicker uses ObjectiveFlickr, which is released under the MIT license. Refer to the ObjectiveFlickr project for details at https://github.com/lukhnos/objectiveflickr.

## TO DO

* Show recent photo as a separate photoset at the top
* Test in a popover on iPad
* Make it only support portrait orientation
