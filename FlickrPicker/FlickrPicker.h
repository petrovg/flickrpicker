//
//  FlickrPicker.h
//  FlickrPicker
//
//  Created by George Petrov on 11/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FlickrPicker : NSObject

@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong) void (^blockToRunWhenAuthorized)(void);

+(FlickrPicker*)sharedFlickrPicker;
-(void) authorize;
-(BOOL) requestToken:(NSURL *)authUrl callbackURL:(NSURL *)callbackURL token:(id)token verifier:(id)verifier;
-(void) getFullAccessWithToken:(NSString *)token andVerifier:(NSString *)verifier;
-(NSURL *)getURLForPhoto:(NSDictionary *)photo;
-(void) getPhotosets:(void (^)(NSArray*))completion;
-(void) getPhotos:(NSString *)photosetId completion:(void (^)(NSArray *))completion;
-(void) getPhoto:(NSString *)photoId completion:(void (^)(NSArray *))completion;
-(void) clearAuthData;
-(BOOL) isAuthorized;
-(void) imagePicked:(NSDictionary *)photoInfo;
-(void) cancel;
-(UIViewController *) flickrImagePickerControllerWithDelegate:(id<UIImagePickerControllerDelegate>)delegate;

@end
