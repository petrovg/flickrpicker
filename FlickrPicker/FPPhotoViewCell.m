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
        CGFloat photoWidth = self.frame.size.width / 4;
        NSMutableArray *btns = [NSMutableArray arrayWithCapacity:4];
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 4; i++)
        {
            CGRect frame = CGRectMake(i * photoWidth, 0, photoWidth, photoWidth);
            UIImageView *image = [[UIImageView alloc] initWithFrame:frame];
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
