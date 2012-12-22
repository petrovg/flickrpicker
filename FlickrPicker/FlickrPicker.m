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

NSString *kSecAttrServiceFlickr = @"kSecAttrServiceFlickr";

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

-(void)authorize
{
    [self.flickrRequest setSessionInfo:@"kFetchRequestTokenStep"];
    [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:@"flickrpicker://auth"]];
}

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
    [[[FlickrPicker sharedFlickrPicker] flickrContext] setOAuthToken:inRequestToken];
    [[[FlickrPicker sharedFlickrPicker] flickrContext] setOAuthTokenSecret:inSecret];
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
    [self saveAuthToken:inAccessToken andSecret:inSecret forUser:inNSID];
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

- (FPFlickrImagePickerController *)flickrImagePickerController
{
	if (!flickrImagePickerController) {
        FPPhotosetsController *photosetsViewController = [[FPPhotosetsController alloc] init];
		flickrImagePickerController = [[FPFlickrImagePickerController alloc] initWithRootViewController:photosetsViewController];
	}
    
	return flickrImagePickerController;
}


#pragma mark Persisting the token and secret
/*
-(NSString *) retrieveSavedAuthTokenAndSecret
{
	CFDictionaryRef *result = nil;
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
						   (__bridge NSString *)kSecClassGenericPassword, kSecClass,
						   kCFBooleanTrue, kSecReturnAttributes,
						   nil];
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);

	if (status != noErr) {
		NSAssert1(status == errSecItemNotFound, @"unexpected error while fetching token from keychain: %ld", status);
		return nil;
	}
    
    CFDictionaryRef savedItem = (CFDictionaryRef) result;
    NSDictionary *savedItemDict = (__bridge NSDictionary *) savedItem;
    NSData *tokenData = [savedItemDict objectForKey:(__bridge id)(kSecAttrGeneric)];
    NSString *token = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
    NSLog(@"Retrieved token %@", token);
	return token;

}
 */

-(CFDictionaryRef) insertQueryForSecureItem:(NSString *)item itemClass:(NSString *)itemClass userNSID:(NSString *)userNSID
{
    NSData *encodedItem = [item dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *insertQuery = [NSDictionary dictionaryWithObjectsAndKeys:
                                 itemClass, kSecClass,
                                 kSecAttrServiceFlickr, kSecAttrService,
                                 userNSID, kSecAttrAccount,
                                 encodedItem, kSecValueData, nil];
    
    
    return (__bridge CFDictionaryRef) insertQuery;
}

-(CFDictionaryRef) searchQueryForSecureItemOfClass:(NSString *)itemClass userNSID:(NSString *)userNSID
{    
    NSDictionary *searchQuery = [NSDictionary dictionaryWithObjectsAndKeys:
                                 itemClass, kSecClass,
                                 kSecAttrServiceFlickr, kSecAttrService,
                                 userNSID, kSecAttrAccount, nil];
    
    
    return (__bridge CFDictionaryRef) searchQuery;
}

-(OSStatus) saveOrReplaceSecItem:(NSString *)item itemClass:(NSString *)itemClass userNSID:(NSString *)userNSID
{
    CFDictionaryRef searchQuery = [self searchQueryForSecureItemOfClass:itemClass userNSID:userNSID];
    OSStatus searchStatus = SecItemCopyMatching(searchQuery, NULL);
    if (searchStatus == noErr)
    {
        SecItemDelete(searchQuery);
        NSLog(@"Deleted existing secure item %@", searchQuery);
    }
    
    CFDictionaryRef insertQuery = [self insertQueryForSecureItem:item itemClass:itemClass userNSID:userNSID];
	OSStatus err = SecItemAdd(insertQuery, NULL);
    return err;
}

-(void) saveAuthToken:(NSString*)token andSecret:(NSString*)secret forUser:(NSString*)userNSID
{
    NSLog(@"Saving token %@", token);
    
    // Save the token
    OSStatus err = [self saveOrReplaceSecItem:token itemClass:(__bridge id)kSecClassGenericPassword userNSID:userNSID];
    NSAssert1(err == noErr, @"error while saving token: %ld", err);
    
    // Save the secret
    err = [self saveOrReplaceSecItem:secret itemClass:(__bridge NSString *)(kSecClassGenericPassword) userNSID:userNSID];
    NSAssert1(err == noErr, @"error while saving password: %ld", err);
}

-(void) deleteAuthToken
{
    
}


@end
