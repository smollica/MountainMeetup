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
#import "Request.h"

@interface EventInfoViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *joinEventButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property(nonatomic) User *user;
@property (nonatomic) NSMutableArray *members;

@end

@implementation EventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.members = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated {
    self.user = (User*)[PFUser currentUser];
    
    self.loadingIndicator.alpha = 0.0;

    PFRelation *relation = [self.event relationForKey:@"members"];
    
    PFQuery *query = [relation query];
    
    [query includeKey:@"myEvent"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        self.members = [results mutableCopy];
        [self.membersCollectionView reloadData];
    }];
    
    self.eventTitleLabel.text = self.event.title;
    self.destinationLabel.text = self.event.destination;
    
    NSDateComponents *dobComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.event.date];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%li / %li / %li", dobComponents.day, dobComponents.month, dobComponents.year];
    
    self.descriptionLabel.text = self.event.summary;
    
    if([self.user.myEvent.objectId isEqualToString:self.event.objectId]) {
        self.joinEventButton.userInteractionEnabled = NO;
        self.joinEventButton.alpha = 0.0;
    }
    

}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.members.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UsersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    
    User *user = [self.members objectAtIndex:indexPath.item];
    
     [self getImageFor:user block:^(UIImage *image) {
         UsersCollectionViewCell *crazyCell = (UsersCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
         crazyCell.userImageView.image = image;
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
                                      alertControllerWithTitle:@"You Are Already a Member of Another Event"
                                      message:@"if you click create an event you will leave the other event\n if you are the leader of that event the event will be terminated"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        UIAlertAction *join = [UIAlertAction
                                 actionWithTitle:@"Join"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self deleteOldEvent];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:cancel];
        [alert addAction:join];
    
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [self joinEvent];
    }
}

-(void)joinEvent {
    self.user.myEvent = self.event;
    
    Request *newRequest = [Request new];
    
    newRequest.creator = self.user;
    
    self.joinEventButton.alpha = 0.0;
    self.joinEventButton.userInteractionEnabled = NO;
    
    self.loadingIndicator.alpha = 1.0;
    [self.loadingIndicator startAnimating];
    
    [newRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"saved");
            [self createRequestAlert];
            
            self.joinEventButton.alpha = 1.0;
            self.loadingIndicator.alpha = 0.0;
            [self.loadingIndicator stopAnimating];
            
            PFQuery *queryE = [Event query];
            
            [queryE whereKey:@"objectId" equalTo:self.event.objectId];
            
            [queryE getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                PFRelation *relationE = [object relationForKey:@"requests"];
                [relationE addObject:newRequest];
                [object saveInBackground];
            }];
        
        }
    }];
}

-(void)deleteOldEvent {
    if([self.user.myEvent.leader isEqualToString:self.user.objectId]) {
        PFQuery *queryE = [Event query];
        
        [queryE whereKey:@"objectId" equalTo:self.user.myEvent.objectId];
        
        [queryE getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            PFQuery *queryU = [User query];
            
            [queryU whereKey:@"myEvent" equalTo:self.user.myEvent];
            
            [queryU findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                for (User *user in objects) {
                    user.myEvent = nil;
                    [user saveInBackground];
                }
                
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [self joinEvent];
                }];
                
            }];
        }];
    } else {
        [self joinEvent];
    }
}

#pragma mark - Alert

-(void)createRequestAlert {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Request Created!"
                                  message:@"congratulations"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showUserProfile2" sender:self];
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