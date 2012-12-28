# FlickrPicker

FlickrPicker is a UIImagePickerController-like class that allow you to select images from Flickr.

FlickrPicker is used the same way as a UIImagePickerController - it is created, assigned a delegate, presented modally and when it finishes it calls the appropriate method of UIImagePickerDelegate.


## Using FlickrPicker

### Get FlickrPicker for github

    git clone https://.....

### Add the FlickrPicker project to your project

* Find FlickrPicker.xcodeproj in finder and drag it to your project
* Add the <path-to-FlickrPicker-root>/FlickrPicker/ to Header Search Paths in Build Settings for your target
* Import FlickerPicker.h where you intend to use FlickrPicker

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

Import FlickrPicker.h in the file where you intend to use it, get an instance, and present it. E.g. like this:

        UIViewController *picker = [[FlickrPicker sharedFlickrPicker] flickrImagePickerControllerWithDelegate:self];
        [self presentViewController:picker animated:YES completion:nil];

The view controller you get is actually a UINavigationController, but you don't need to worry about this - the standard UIImagePickerController is also a UINavigationController, by virtue of subclassing it, but Apple don't won't you to sublass it, so I went for an actual instance of it. There's also some dodgy going-ons with the UIImagePickerController's delegate shadowing the UINavigationController delegate - in this way I avoid having to use the same delegate property for both.

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
