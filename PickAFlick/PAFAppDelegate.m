//
//  AppDelegate.m
//  PickAFlick
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "PAFAppDelegate.h"
#import "FlickrPicker.h"

@implementation PAFAppDelegate

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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"2) Did enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Will enter foreground");
}




@end
