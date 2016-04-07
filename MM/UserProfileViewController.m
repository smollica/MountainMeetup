//
//  UserProfileViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "UserProfileViewController.h"

@interface UserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dobLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    User *me = (User*)[PFUser currentUser];
    
    if(self.user == nil) {
        self.user = me;
    }
    
    if(self.user.myEvent.leader != me || self.user == me) {
        self.acceptButton.userInteractionEnabled = NO;
        self.acceptButton.alpha = 0.0;
        self.declineButton.userInteractionEnabled = NO;
        self.declineButton.alpha = 0.0;
    }
    
    [self getImageForProfile];
    self.displayNameLabel.text = self.user.displayName;
    
    NSDateComponents *dobComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.user.dob];
    
    self.dobLabel.text = [NSString stringWithFormat:@"%li / %li / %li", dobComponents.day, dobComponents.month, dobComponents.year];
    
    if(self.user.isDriving) {
        self.driverStatusLabel.text = @"Driver";
    } else {
        self.driverStatusLabel.text = @"Passenger";
    }
    
    self.introLabel.text = self.user.intro;
}

- (void)getImageForProfile {
    PFQuery *query = [User query];
    
    [query whereKey:@"username" equalTo:self.user.username];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            return NSLog(@"No Object and %@", error);
        }
        
        PFFile *imageFile = object[@"image"];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!data) {
                return NSLog(@"No Image File and %@", error);
            }
        
            self.userProfileImage.image = [UIImage imageWithData:data];
        }];
    }];
}

#pragma mark - Actions (buttons)

- (IBAction)acceptButtonPressed:(id)sender {
    //handle acceptance locally and in Parse
    self.acceptButton.userInteractionEnabled = NO;
    self.acceptButton.alpha = 0.0;
}
- (IBAction)declineButtonPressed:(id)sender {
    //handle decline locally and in Parse
    self.declineButton.userInteractionEnabled = NO;
    self.declineButton.alpha = 0.0;
}

@end