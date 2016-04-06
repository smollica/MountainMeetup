//
//  MyEventViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "MyEventViewController.h"
#import "UsersCollectionViewCell.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Event.h"

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
    
    for (User *user in self.event.members) {
        [self.members addObject:user];
    }
    
    for (User *user in self.event.requests) {
        [self.requests addObject:user];
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
            
            //cell.UserPFImageView = user.image;
            //cell.displayNameLabel.text = user.displayName;
            
            return cell;
            
        } else {
            
            UsersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
            
            User *user = [self.requests objectAtIndex:indexPath.item];
            
            //cell.UserPFImageView = user.image;
            //cell.displayNameLabel.text = user.displayName;
            
            return cell;
        }
}

@end