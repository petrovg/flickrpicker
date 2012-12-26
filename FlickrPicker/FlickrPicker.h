//
//  FlickrPicker.h
//  FlickrPicker
//
//  Created by George Petrov on 11/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveFlickr.h"
#import <UIKit/UIKit.h>

@interface FlickrPicker : NSObject <OFFlickrAPIRequestDelegate>

@property (nonatomic, strong, readonly) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong, readonly) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong) void (^blockToRunWhenAuthorized)(void);

+(FlickrPicker*)sharedFlickrPicker;
-(void) authorize;
-(void) getPhotosets:(void (^)(NSArray*))completion;
-(void) getPhotos:(NSString *)photosetId completion:(void (^)(NSArray *))completion;
-(void) getPhoto:(NSString *)photoId completion:(void (^)(NSArray *))completion;
-(void) clearAuthData;
-(BOOL) isAuthorized;
-(void) imagePicked:(NSDictionary *)photoInfo;
-(void) cancel;
-(UIViewController *) flickrImagePickerControllerWithDelegate:(id<UIImagePickerControllerDelegate>)delegate;

@end
