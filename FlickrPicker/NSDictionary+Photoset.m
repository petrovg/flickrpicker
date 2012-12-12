//
//  NSDictionary+Photoset.m
//  FlickrPicker
//
//  Created by George Petrov on 12/12/2012.
//  Copyright (c) 2012 George Petrov. All rights reserved.
//

#import "NSDictionary+Photoset.h"
#import "FlickrPicker.h"

@implementation NSDictionary (Photoset)

-(NSString *) photosetName
{
    if ([self valueForKeyPath:@"title._text"])
    {
        return [self valueForKeyPath:@"title._text"];
    }
    else if ([self valueForKey:@"_text"])
    {
        return [self valueForKey:@"_text"];
    }
    else return @"";
}


@end
