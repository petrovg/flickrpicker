//
//  AppDelegate.m
//  PickAFlick
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "PAPAppDelegate.h"
#import "FlickrPicker.h"

@implementation PAPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"1) Did finish launching with options: %@", launchOptions);
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Opening url %@", url);
    NSString *token = nil;
    NSString *verifier = nil;
    BOOL result = [[FlickrPicker sharedFlickrPicker] requestToken:url callbackURL:[NSURL URLWithString:@"flickrpicker://auth"] token:token verifier:verifier];
    
    if (!result) {
        NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
        return NO;
    }
    
    [[FlickrPicker sharedFlickrPicker] getFullAccessWithToken:token andVerifier:verifier];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"2) Did enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Will enter foreground");
}




@end
