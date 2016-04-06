//
//  User.h
//  MM
//
//  Created by Monica Mollica on 2016-04-05.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import <Parse/Parse.h>
@class Event;

@interface User : PFUser

@property (nonatomic) PFFile *image;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *intro;
@property (nonatomic) NSDate *dob;
@property (nonatomic) BOOL isDriving;
@property (nonatomic) PFGeoPoint *location;
@property (nonatomic, weak) Event *myEvent;

@end
