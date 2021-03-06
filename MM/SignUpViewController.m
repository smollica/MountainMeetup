//
//  SignUpViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "SignUpViewController.h"
#import "User.h"

@interface SignUpViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *introTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *dobDatePicker;
@property (weak, nonatomic) IBOutlet UISwitch *isDrivingSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *createProfileButton;
@property (nonatomic) User *user;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userImageView.userInteractionEnabled = YES;
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.displayNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.introTextField.delegate = self;
    
    self.loadingIndicator.alpha = 0.0;
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.userImageView.image = image;
}

- (void)getPhotosButton:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)getCameraButton:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Actions (buttons)

- (IBAction)imagePickerButtonPressed:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Please Pick a Photo"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *camera = [UIAlertAction
                         actionWithTitle:@"Camera"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self getCameraButton:self];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction *photos = [UIAlertAction
                             actionWithTitle:@"Photos"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self getPhotosButton:self];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:camera];
    [alert addAction:photos];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)createProfileButtonPressed:(id)sender {
    
    User *newUser = [User new];
    
    self.loadingIndicator.alpha = 1.0;
    [self.loadingIndicator startAnimating];
    self.cancelButton.alpha = 0.0;
    self.cancelButton.userInteractionEnabled = NO;
    self.createProfileButton.alpha = 0.0;
    self.createProfileButton.userInteractionEnabled = NO;

    UIImage *userImage = self.userImageView.image;
    NSData *userImageData = UIImageJPEGRepresentation(userImage, 0.9);
    
    if(userImageData != nil) {
        PFFile *imageFile = [PFFile fileWithData:userImageData];
        newUser.image = imageFile;
    }

    newUser.username = self.usernameTextField.text;
    newUser.password = self.passwordTextField.text;
    newUser.displayName = self.displayNameTextField.text;
    newUser.email = self.emailTextField.text;
    newUser.intro = self.introTextField.text;
    newUser.dob = self.dobDatePicker.date;
    newUser.isDriving = self.isDrivingSwitch.state;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self createProfileAlert:(error.localizedDescription)];
        } else {
            NSLog(@"saved");
            self.user = newUser;
            [self performSegueWithIdentifier:@"createProfileSegue" sender:self];
        }
        self.loadingIndicator.alpha = 0.0;
        [self.loadingIndicator stopAnimating];
        self.cancelButton.alpha = 1.0;
        self.cancelButton.userInteractionEnabled = YES;
        self.createProfileButton.alpha = 1.0;
        self.createProfileButton.userInteractionEnabled = YES;
    }];
}

- (IBAction)backButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"unwindToHome" sender:self];
}

#pragma mark - Alert

-(void)createProfileAlert:(NSString*)error {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Invalid Profile Information"
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

-(IBAction)unwindFromSignUp:(UIStoryboardSegue *)unwindSegue {
    [self performSegueWithIdentifier:@"unwindToHome" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"createProfileSegue"]) {
        //
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

@end