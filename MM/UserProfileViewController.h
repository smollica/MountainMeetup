//
//  UserProfileViewController.h
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Event.h"
#import "Request.h"

@interface UserProfileViewController : UIViewController

@property (nonatomic) User *user;
@property (nonatomic) Event *event;
@property (nonatomic) Request *request;

@end