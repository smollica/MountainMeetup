//
//  HomeViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "HomeViewController.h"
#import "User.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *homeImageView;
@property (nonatomic) User *user;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.homeImageView.image = [UIImage imageNamed:@"name"];<----add image here;
    
}


#pragma mark - Actions (buttons)


- (IBAction)signInButtonPressed:(id)sender {
    UIAlertController *alert = [UIAlertController
                                          alertControllerWithTitle:@"Please Log In"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Username";
     }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Password";
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *login = [UIAlertAction
                            actionWithTitle:@"Log In"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *username = alert.textFields.firstObject;
                                   UITextField *password = alert.textFields.lastObject;
                                   
                                   [PFUser logInWithUsernameInBackground:username.text
                                                                password:password.text
                                                                   block:^(PFUser *user, NSError *error)
                                    {
                                        if(!error) {
                                            NSLog(@"Login Successful.");
                                            [self performSegueWithIdentifier:@"signInSegue" sender:self];
                                        } else {
                                            NSLog(@"Error");
                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                            [self invalidLogin:(error.localizedDescription)];
                                        }
                                    }];
                                   
                                   if(alert) {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }
                               }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:cancel];
    [alert addAction:login];

    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)invalidLogin:(NSString*)error {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Invalid Login"
                                  message:error
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

#pragma mark - Segue

-(IBAction)unwindFromSignUp:(UIStoryboardSegue*)unwindSegue {
    //returns to main page when hits cancel on signUpViewController
}

@end