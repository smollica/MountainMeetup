//
//  Event.h
//  MM
//
//  Created by Monica Mollica on 2016-04-05.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"

@interface Event : PFObject <PFSubclassing>

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *summary;
@property (nonatomic) User *leader;
@property (nonatomic) PFFile *image;
@property (nonatomic) NSDate *date;
@property (nonatomic) PFGeoPoint *location;
@property (nonatomic) double distance;
@property (nonatomic) NSMutableSet *members; //contains PFUsers
@property (nonatomic) NSMutableSet *requests; //contains PFObjects

+ (NSString*)parseClassName;

@end
