//
//  Request.h
//  MM
//
//  Created by Monica Mollica on 2016-04-05.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "Request.h"

@interface Request : PFObject <PFSubclassing>

@property (nonatomic) User *creator;
@property (nonatomic) NSString *comment;
@property (nonatomic) BOOL *accepted;

@end
