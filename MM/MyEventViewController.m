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
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (nonatomic) User *user;
@property (nonatomic) Event *event;
@property (nonatomic) NSMutableArray *members;
@property (nonatomic) NSMutableArray *requests;

@end

@implementation MyEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.members =  [NSMutableArray new];
    self.requests =  [NSMutableArray new];
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.user = (User*)[PFUser currentUser];
    self.event = self.user.myEvent;
    
    if(self.event == nil) {
        
        //self.coverImageView.image = [UIImage imageNamed:@"name"];<----add image here;
        self.coverImageView.alpha = 1.0;
        
    } else {
    
        self.coverImageView.alpha = 0.0;
        
        PFRelation *relationM = [self.event relationForKey:@"members"];
        PFQuery *queryM = [relationM query];
        [queryM findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            self.members = [results mutableCopy];
            [self.confirmedCollectionView reloadData];
        }];
        
        PFRelation *relationR = [self.event relationForKey:@"requests"];
        PFQuery *queryR = [relationR query];
        [queryR findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            self.requests = [results mutableCopy];
            [self.requestsCollectionView reloadData];
        }];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(collectionView == self.confirmedCollectionView) {
        return self.members.count;
    } else {
        return self.requests.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UsersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    
        if(collectionView == self.confirmedCollectionView) {
            
            User *user = [self.members objectAtIndex:indexPath.item];
            
            [self getImageFor:user block:^(UIImage *image) {
                UsersCollectionViewCell *crazyCell = (UsersCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                crazyCell.userImageView.image = image;
            }];
            
            cell.displayNameLabel.text = user.displayName;
        
            
        } else {
        
            User *user = [self.requests objectAtIndex:indexPath.item];
            
            [self getImageFor:user block:^(UIImage *image) {
                cell.userImageView.image = image;
                UsersCollectionViewCell *crazyCell = (UsersCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                crazyCell.userImageView.image = image;
            }];
            
            cell.displayNameLabel.text = user.displayName;
            
        }
    
    return cell;
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
            vc.request = request;
        }
 
    }
}

@end