//
//  Request.m
//  MM
//
//  Created by Monica Mollica on 2016-04-05.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "Request.h"

@implementation Request

@dynamic creator;
@dynamic comment;
@dynamic accepted;


+ (NSString*)parseClassName {
    return @"Request";
}


@end
