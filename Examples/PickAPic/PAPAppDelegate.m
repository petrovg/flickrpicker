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
    NSLog(@"Request to open url %@", url);
    static NSString *authCallbackURL = @"pickapic://auth";
    if ([[url absoluteString] rangeOfString:authCallbackURL].location == 0)
    {
        [[FlickrPicker sharedFlickrPicker] requestToken:url callbackURL:[NSURL URLWithString:authCallbackURL]];
    }
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
