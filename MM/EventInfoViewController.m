//
//  EventInfoViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "EventInfoViewController.h"
#import "UsersCollectionViewCell.h"
#import "UserProfileViewController.h"
#import "User.h"

@interface EventInfoViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property (nonatomic) NSMutableArray *members;
@property(nonatomic) User *user;

@end

@implementation EventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = (User*)[PFUser currentUser];
    
    for (User *user in self.event.members) {
        [self.members addObject:user];
    }
    
    self.eventTitleLabel.text = self.event.title;
    //add other info
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.event.members.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UsersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    
    User *user = [self.members objectAtIndex:indexPath.item];
    
     [self getImageFor:user block:^(UIImage *image) {
         cell.userImageView.image = image;
     }];
    
    cell.displayNameLabel.text = user.displayName;
    
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

#pragma mark - Actions (buttons)

- (IBAction)joinButtonPressed:(id)sender {
    
    if(self.user.myEvent != nil) {
    
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"You Are Already a member of Another Event"
                                      message:@"if you click join you will leave the other event"
                                      preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *join = [UIAlertAction
                                 actionWithTitle:@"Join"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     
                                     self.user.myEvent = self.event;
                                     [self performSegueWithIdentifier:@"joinEventSegue" sender:self];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 }];
    
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 }];
    
        [alert addAction:join];
        [alert addAction:cancel];
    
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
    
        self.user.myEvent = self.event;
        [self performSegueWithIdentifier:@"joinEventSegue" sender:self];

    }
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showUserProfile2"]) {
        
        NSIndexPath *indexPath = [[self.membersCollectionView indexPathsForSelectedItems] firstObject];
        UserProfileViewController *vc = segue.destinationViewController;
        vc.user = self.members[indexPath.row];
        vc.event = self.event;
    }
}

@end