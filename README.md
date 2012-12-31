# FlickrPicker

FlickrPicker provides a controller similar to UIImagePickerController which allows you to select images from Flickr.

FlickrPicker is used the same way as a UIImagePickerController - it is created with a delegate, presented modally and when it finishes it calls the appropriate method of UIImagePickerDelegate.


## Using FlickrPicker

### Get FlickrPicker from github

    git clone https://github.com/petrovg/flickrpicker


### Add the FlickrPicker project to your project

* Find FlickrPicker.xcodeproj in finder and drag it to your project
* Add the <path-to-FlickrPicker-root>/FlickrPicker/ to Header Search Paths in Build Settings for your target
* Import FlickerPicker.h where you intend to use FlickrPicker

### Create a callback URL so that your app can be notified after user authorizes it

The callback URL is used to return to your app after the user has authorized it in Safari

* In your app target choose the Info tab
* Open URL Types
* Enter a unique identifier, i.e. com.yourdomain.yourapp
* Enter a url scheme - your app name could be a good candidate


### Add dependencies

Go to your target, chose the Build Phases tab and in Link Binary with Libraries, add the following:

* Security.framework
* CFNetwork.framework
* SystemConfiguration.framework

### Implement the openURL method in your AppDelegate

This is neccessary, so that Safari can re-launch your app once the user has authorized access to their Flickr account. If it was launched using the authorization URL chosen by you (in the example below pickapic://auth", it goes off to Flickr and gets an authorization token and secret, which are then stored for further use.

    -(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        NSLog(@"Request to open url %@", url);
        static NSString *authCallbackURL = @"pickapic://auth";
        if ([[url absoluteString] rangeOfString:authCallbackURL].location == 0)
        {
            [[FlickrPicker sharedFlickrPicker] requestToken:url callbackURL:[NSURL URLWithString:authCallbackURL]];
        }
        return YES;
    }



### Get and present a FlickrPicker view controller:

Import FlickrPicker.h in the file where you intend to use it, get an instance, and present it. E.g. like this:

    UIViewController *picker = [[FlickrPicker sharedFlickrPicker] flickrImagePickerControllerWithDelegate:self authCallbackURL:[NSURL URLWithString:@"pickapic://auth"]];
    [self presentViewController:picker animated:YES completion:nil];


The view controller you get is actually a UINavigationController, but you don't need to worry about this - the standard UIImagePickerController is also a UINavigationController. The authCallbackURL must match the one given in the AppDelegate (see above).


### Dismiss the controller when an image is selected or selection is cancelled

Just like with a standard UIImagePickerController, the FlickrPicker controller must be dismissed after the user picks an image or cancels:

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

* Show recent photos as a separate photoset at the top
* Test in a popover on iPad
* Make it only support portrait orientation
