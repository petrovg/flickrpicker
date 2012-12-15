//
//  ViewController.h
//  PickAFlick
//
//  Created by George Petrov on 06/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAPViewController : UIViewController <UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *pickButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end
