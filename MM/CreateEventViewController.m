//
//  CreateEventViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "CreateEventViewController.h"
#import "Event.h"

@interface CreateEventViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventImageView.backgroundColor = [UIColor grayColor];
    self.eventImageView.userInteractionEnabled = YES;
    
    //self.usernameTextField.delegate = self;
    //self.passwordTextField.delegate = self;
}


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.eventImageView.image = image;
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

- (IBAction)createEventButton:(id)sender {
    
    Event *newEvent = [Event new];
    
    UIImage *eventImage = self.eventImageView.image;
    NSData *eventImageData = UIImageJPEGRepresentation(eventImage, 0.9);
    
    if(eventImageData != nil) {
        PFFile *imageFile = [PFFile fileWithData:eventImageData];
        newEvent.image = imageFile;
    }
    
    newEvent.date = self.eventDatePicker.date;
    
    [newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"saved");
            //[self performSegueWithIdentifier:@"createEventSegue" sender:self];
        }
    }];
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"createEventSegue"]) {
        //EventsListViewController *vc = segue.destinationViewController;
        //vc.user = self.user;
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}


@end
