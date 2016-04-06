//
//  MyEventViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "MyEventViewController.h"
#import "UsersCollectionViewCell.h"
#import "UserProfileViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Event.h"
#import "Request.h"

@interface MyEventViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *confirmedCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *requestsCollectionView;
@property (nonatomic) User *user;
@property (nonatomic) Event *event;
@property (nonatomic) NSMutableArray *members;
@property (nonatomic) NSMutableArray *requests;

@end

@implementation MyEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = (User*)[PFUser currentUser];
    self.event = self.user.myEvent;
    
    if(self.event == nil) {
        
        self.eventTitleLabel.text = @"Not a Member of Any Events";
        
    } else {
    
        for (User *user in self.event.members) {
            [self.members addObject:user];
        }
        
        for (User *user in self.event.requests) {
            [self.requests addObject:user];
        }
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(collectionView == self.confirmedCollectionView) {
        return self.event.members.count;
    } else {
        return self.event.requests.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
        if(collectionView == self.confirmedCollectionView) {
    
            UsersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
            
            User *user = [self.members objectAtIndex:indexPath.item];
            
            [self getImageFor:user block:^(UIImage *image) {
                cell.userImageView.image = image;
            }];
            
            cell.displayNameLabel.text = user.displayName;
            
            return cell;
            
        } else {
            
            UsersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
            
            User *user = [self.requests objectAtIndex:indexPath.item];
            
            [self getImageFor:user block:^(UIImage *image) {
                cell.userImageView.image = image;
            }];
            
            cell.displayNameLabel.text = user.displayName;
            
            return cell;
        }
}

- (void)getImageFor:(User*)user block:(void (^)(UIImage *image))completionBlock{
    PFQuery *query = [User query];
    
    [query whereKey:@"username" equalTo:user.username];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            return NSLog(@"No Object and %@", error);
        }
        
        PFFile *imageFile = object[@"image"];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!data) {
                return NSLog(@"No Image File and %@", error);
            }
            
            completionBlock([UIImage imageWithData:data]);
        }];
    }];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showUserProfile"]) {
        if(sender == self.confirmedCollectionView) {
            NSIndexPath *indexPath = [[self.confirmedCollectionView indexPathsForSelectedItems] firstObject];
            UserProfileViewController *vc = segue.destinationViewController;
            vc.user = self.members[indexPath.row];
            vc.event = self.event;
        } else {
            NSIndexPath *indexPath = [[self.requestsCollectionView indexPathsForSelectedItems] firstObject];
            UserProfileViewController *vc = segue.destinationViewController;
            Request *request = self.requests[indexPath.row];
            vc.user = request.creator;
            vc.event = self.event;
        }
 
    }
}

@end