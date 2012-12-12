//
//  FlickrPicker.m
//  FlickrPicker
//
//  Created by George Petrov on 11/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FlickrPicker.h"
#import <UIKit/UIKit.h>

NSString *kStoredAuthTokenKeyName = @"FlickrOAuthToken";
NSString *kStoredAuthTokenSecretKeyName = @"FlickrOAuthTokenSecret";
NSString *kFPRequestSessionGettingPhotosets = @"kFPequestSessionGettingPhotosets";
NSString *kFPPhotoSetTypePhotoset = @"kFPPhotoSetTypePhotoset";
NSString *kFPPhotoSetTypeTag = @"kFPPhotoSetTypeTag";


@interface FlickrPicker ()

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) void (^blockToRunAfterGettingPhotosets)(NSArray*);

@end


@implementation FlickrPicker
{
    OFFlickrAPIContext *flickrContext;
    OFFlickrAPIRequest *flickrRequest;
}

+(FlickrPicker*)sharedFlickrPicker
{
    static FlickrPicker *flickrPicker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        flickrPicker = [[FlickrPicker alloc] init];
    });
    return flickrPicker;
}

-(void)authorize
{
    [self.flickrRequest setSessionInfo:@"kFetchRequestTokenStep"];
    [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:@"flickrpicker://auth"]];
}

void requestPhotosets(OFFlickrAPIRequest *request)
{
    // Initialise the context and request and ask for the photoset list
    NSLog(@"Requesting photosets");
    request.sessionInfo = kFPRequestSessionGettingPhotosets;
    [request setSessionInfo:kFPRequestSessionGettingPhotosets];
    [request callAPIMethodWithGET:@"flickr.photosets.getList" arguments:nil];
}

-(void)getPhotosets:(void (^)(NSArray *))completion
{
    self.blockToRunAfterGettingPhotosets = completion;
    requestPhotosets(self.flickrRequest);
}

#pragma mark OFFlickrAPIRequestDelegate
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
    NSLog(@"Got token: %@ and secret: %@", inRequestToken, inSecret);
    [[[FlickrPicker sharedFlickrPicker] flickrContext] setOAuthToken:inRequestToken];
    [[[FlickrPicker sharedFlickrPicker] flickrContext] setOAuthTokenSecret:inSecret];
    NSURL *authURL = [[FlickrPicker sharedFlickrPicker].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrReadPermission];
    NSLog(@"Opening authURL %@", authURL);
    [[UIApplication sharedApplication] openURL:authURL];
}

-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    NSLog(@"Got access token: %@, secret %@, user full name %@", inAccessToken, inSecret, inFullName);
    self.flickrContext.OAuthToken = inAccessToken;
    self.flickrContext.OAuthTokenSecret = inSecret;
    self.userId = inNSID;
    self.blockToRunWhenAuthorized();
}

-(void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    NSLog(@"Response received for session: %@", self.flickrRequest.sessionInfo);
    if (self.flickrRequest.sessionInfo == kFPRequestSessionGettingPhotosets
        )
    {
        NSArray *photosets = [inResponseDictionary valueForKeyPath:@"photosets.photoset"];
        self.blockToRunAfterGettingPhotosets(photosets);
        [self setBlockToRunWhenAuthorized:nil];
        [self.flickrRequest setSessionInfo:nil];
    }
}

-(void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"Error : %@", inError);
}

# pragma mark flickr request and context properties
- (OFFlickrAPIContext *)flickrContext
{
    if (!flickrContext) {
        flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
        
        NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenKeyName];
        NSString *authTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenSecretKeyName];
        
        if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
            flickrContext.OAuthToken = authToken;
            flickrContext.OAuthTokenSecret = authTokenSecret;
        }
    }
    
    return flickrContext;
}

- (OFFlickrAPIRequest *)flickrRequest
{
	if (!flickrRequest) {
		flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
	}
    
    // This is the default delegate
    flickrRequest.delegate = self;
	
	return flickrRequest;
}



@end
