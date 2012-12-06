//
//  FlickrPicker.h
//  FlickrPicker
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//
// This controller is a table, which shows a list of the available
// photosets from Flickr and the additional photoset named Recent, containing
// recently added photos
//

@interface FPFlickrImagePickerController : UITableViewController

// The delegate that will be notified when the image picking is complete
@property (weak, nonatomic) id <UITableViewDelegate> delegate;


@end
