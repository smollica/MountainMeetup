//
//  EventInfoViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "EventInfoViewController.h"
#import "UsersCollectionViewCell.h"
#import "User.h"

@interface EventInfoViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property (nonatomic) NSMutableArray *members;

@end

@implementation EventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (User *user in self.event.members) {
        [self.members addObject:user];
    }
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.event.members.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UsersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    
    User *user = [self.members objectAtIndex:indexPath.item];
    
    //cell.UserPFImageView = user.image;
    //cell.displayNameLabel.text = user.displayName;
    
    return cell;
}

@end