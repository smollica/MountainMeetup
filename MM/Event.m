//
//  Event.m
//  MM
//
//  Created by Monica Mollica on 2016-04-05.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "Event.h"

@implementation Event

@dynamic title;
@dynamic summary;
@dynamic leader;
@dynamic image;
@dynamic date;
@dynamic location;
@dynamic distance;

+ (NSString*)parseClassName {
    return @"Event";
}

@end
