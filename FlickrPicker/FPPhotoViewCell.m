//
//  PhotoViewCell.m
//  FlickrPicker
//
//  Created by George Petrov on 03/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "FPPhotoViewCell.h"


@implementation FPImageSelectionButton

@end



@implementation FPPhotoViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        static CGFloat m = 4.0; // margin
        static CGFloat n = 4;   // number of pics per cell
        CGFloat W = self.frame.size.width; // total frame width
        CGFloat w =  (W - (n + 1) * m) / n; // image width
        
        NSMutableArray *btns = [NSMutableArray arrayWithCapacity:n];
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:n];
        for (int i = 0; i < 4; i++)
        {
            CGFloat x = (i + 1) * m + i * w;
            CGRect frame = CGRectMake(x, m , w, w);
            UIImageView *image = [[UIImageView alloc] initWithFrame:frame];
            [image setBackgroundColor:[UIColor lightGrayColor]];
            [imgs setObject:image atIndexedSubscript:i];
            [self addSubview:image];
            FPImageSelectionButton *button = [[FPImageSelectionButton alloc] initWithFrame:frame];
            [btns setObject:button atIndexedSubscript:i];
            [self addSubview:button];
        }
        self.images = [NSArray arrayWithArray:imgs];
        self.buttons = [NSArray arrayWithArray:btns];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
