//
//  FlickrPicker.m
//  FlickrPicker
//
//  Created by George Petrov on 11/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FlickrPicker.h"
#import <UIKit/UIKit.h>
#import "FPFlickrImagePickerController.h"
#import "FPPhotosetsController.h"
#import "SimpleKeychain.h"

NSString *kFPSecAttrServiceFlickr = @"kSecAttrServiceFlickr";
NSString *kFPAuthTokenKey = @"kFPAuthTokenKey";
NSString *kFPAuthSecretKey = @"kFPAuthSecretKey";
NSString *kFPAuthNSIDKey = @"kFPAuthNSIDKey";

NSString *kFPRequestSessionGettingPhotosets = @"kFPequestSessionGettingPhotosets";
NSString *kFPRequestSessionGettingPhotos = @"kFPequestSessionGettingPhotos";
NSString *kFPPhotoSetTypePhotoset = @"kFPPhotoSetTypePhotoset";
NSString *kFPPhotoSetTypeTag = @"kFPPhotoSetTypeTag";


@interface FlickrPicker ()

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) void (^blockToRunAfterGettingPhotosets)(NSArray*);
@property (nonatomic, strong) void (^blockToRunAfterGettingPhotos)(NSArray*);
@property (nonatomic, strong) void (^blockToRunAfterGettingAPhoto)(NSArray*);

@end


@implementation FlickrPicker
{
    OFFlickrAPIContext *flickrContext;
    OFFlickrAPIRequest *flickrRequest;
    FPFlickrImagePickerController *flickrImagePickerController;
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

#pragma mark Getting an image picker controller
- (FPFlickrImagePickerController *)flickrImagePickerController
{
	if (!flickrImagePickerController) {
        FPPhotosetsController *photosetsViewController = [[FPPhotosetsController alloc] init];
		flickrImagePickerController = [[FPFlickrImagePickerController alloc] initWithRootViewController:photosetsViewController];
	}
    
	return flickrImagePickerController;
}

#pragma mark Authorization
-(void)authorize
{
    NSDictionary *storedAuthData = [SimpleKeychain load:kFPSecAttrServiceFlickr];
 
    if (storedAuthData)
    {
        NSLog(@"Stored auth data found: %@", storedAuthData);
        self.flickrContext.OAuthToken = [storedAuthData objectForKey:kFPAuthTokenKey];
        self.flickrContext.OAuthTokenSecret = [storedAuthData objectForKey:kFPAuthSecretKey];
        self.userId = [storedAuthData objectForKey:kFPAuthNSIDKey];
        self.blockToRunWhenAuthorized();
    }
    else {
        // No store auth data available - initiate authorization session
        NSLog(@"No stored auth data - initiating auth session");
        [self.flickrRequest setSessionInfo:@"kFetchRequestTokenStep"];
        [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:@"flickrpicker://auth"]];
    }
}

-(void)clearAuthData
{
    [SimpleKeychain delete:kFPSecAttrServiceFlickr];
    NSLog(@"Authorization data deleted");
}

-(BOOL)isAuthorized
{
    return self.flickrContext.OAuthToken.length ? YES : NO;
}


#pragma mark Getting stuff from Flickr
-(void)getPhotosets:(void (^)(NSArray *))completion
{
    self.blockToRunAfterGettingPhotosets = completion;
    // Initialise the context and request and ask for the photoset list
    NSLog(@"Requesting photosets");
    self.flickrRequest.sessionInfo = kFPRequestSessionGettingPhotosets;
    [self.flickrRequest setSessionInfo:kFPRequestSessionGettingPhotosets];
    [self.flickrRequest callAPIMethodWithGET:@"flickr.photosets.getList" arguments:nil];
}

-(void)getPhotos:(NSString *)photosetId completion:(void (^)(NSArray *))completion
{
    self.blockToRunAfterGettingPhotos = completion;
    // Initialise the context and request and ask for the photos
    NSLog(@"Requesting photos");
    self.flickrRequest.sessionInfo = kFPRequestSessionGettingPhotos;
    [self.flickrRequest setSessionInfo:kFPRequestSessionGettingPhotos];
    [[self flickrRequest] callAPIMethodWithGET:@"flickr.photosets.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:photosetId, @"photoset_id", nil]];
}

-(void)getPhoto:(NSString *)photoId completion:(void (^)(NSArray *))completion
{
    self.blockToRunAfterGettingAPhoto = completion;
    // Initialise the context and request and ask for the photos
    NSLog(@"Requesting photos");
    self.flickrRequest.sessionInfo = kFPRequestSessionGettingPhotos;
    [self.flickrRequest setSessionInfo:kFPRequestSessionGettingPhotos];
}

#pragma mark OFFlickrAPIRequestDelegate
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
    NSLog(@"Got token: %@ and secret: %@", inRequestToken, inSecret);
    [self.flickrContext setOAuthToken:inRequestToken];
    [self.flickrContext setOAuthTokenSecret:inSecret];
    NSURL *authURL = [[FlickrPicker sharedFlickrPicker].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrReadPermission];
    NSLog(@"Opening authURL %@", authURL);
    [[UIApplication sharedApplication] openURL:authURL];
}

-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    NSLog(@"Got access token: %@, secret %@, user full name %@ and id %@", inAccessToken, inSecret, inFullName, inNSID);
    self.flickrContext.OAuthToken = inAccessToken;
    self.flickrContext.OAuthTokenSecret = inSecret;
    self.userId = inNSID;
    
    // Save the token and secret
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:inAccessToken, kFPAuthTokenKey, inSecret,kFPAuthSecretKey, inNSID, kFPAuthNSIDKey, nil];
    [SimpleKeychain save:kFPSecAttrServiceFlickr data:authData];
    
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
    else if (self.flickrRequest.sessionInfo == kFPRequestSessionGettingPhotos)
    {
        NSArray *photos = [inResponseDictionary valueForKeyPath:@"photoset.photo"];
        self.blockToRunAfterGettingPhotos(photos);
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
        
        NSString *authToken = nil;
        NSString *authTokenSecret = nil;
        
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


#pragma mark Cancel selection
-(void)cancel
{
    id<UIImagePickerControllerDelegate> delegate = self.flickrImagePickerController.delegate;
    [delegate imagePickerControllerDidCancel:self.flickrImagePickerController];
}

@end
