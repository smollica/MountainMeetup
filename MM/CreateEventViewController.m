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
@property (weak, nonatomic) IBOutlet UITextField *eventTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (weak, nonatomic) IBOutlet UITextField *eventDescriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *createEventButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic) User *user;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    self.user = (User*)[PFUser currentUser];
    
    self.eventImageView.userInteractionEnabled = YES;
    
    self.eventTitleTextField.delegate = self;
    self.destinationTextField.delegate = self;
    self.eventDescriptionTextField.delegate = self;
    
    self.loadingIndicator.alpha = 0.0;
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
    
    newEvent.title = self.eventTitleTextField.text;
    newEvent.summary = self.eventDescriptionTextField.text;
    newEvent.destination = self.destinationTextField.text;
    newEvent.date = self.eventDatePicker.date;
    newEvent.location = self.user.location;
    newEvent.leader = self.user.objectId;
    
    PFRelation *relationM = [newEvent relationForKey:@"members"];
    [relationM addObject:self.user];
    
    self.user.myEvent = newEvent;
    
    [self.user saveInBackground];
    
    self.createEventButton.alpha = 0.0;
    self.createEventButton.userInteractionEnabled = NO;
    
    self.loadingIndicator.alpha = 1.0;
    [self.loadingIndicator startAnimating];
    
    [newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"saved");
            self.user.myEvent = newEvent;
            [self createEventAlert];
            
            self.createEventButton.alpha = 1.0;
            self.loadingIndicator.alpha = 0.0;
            [self.loadingIndicator stopAnimating];
        }
    }];
}

#pragma mark - Alert

-(void)createEventAlert {

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Event Created!"
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

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

@end