//
//  EventsListViewController.m
//  MM
//
//  Created by Monica Mollica on 2016-04-04.
//  Copyright © 2016 Sergio Mollica. All rights reserved.
//

#import "EventsListViewController.h"
#import "Event.h"
#import "EventsListTableViewCell.h"
#import "EventInfoViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface EventsListViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic) BOOL didInputLocation;
@property (nonatomic) NSString *currentPostalCode;
@property (nonatomic) NSMutableArray *localEvents;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EventsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchTextField.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self getCurrentLocation];

}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    if(self.didInputLocation == NO){
        if (!self.lastLocation) {
            MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
            MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, span);
            [self.mapView setRegion:region animated:YES];
            
            CLGeocoder *geo = [[CLGeocoder alloc] init];
            
            [geo reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                
                CLPlacemark *place = [placemarks objectAtIndex:0];
                self.currentPostalCode = place.postalCode;
                
                [self fetchData];
                
            }];
        }
    }
    
    self.lastLocation = currentLocation;
}

- (void)fetchData {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    if(self.user.location != nil) {
        [query whereKey:@"location" nearGeoPoint:self.user.location];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (Event *event in objects) {
                if(self.user.location != nil) {
                    event.distance = [event.location distanceInKilometersTo:self.user.location]/1000;
                    [self.localEvents addObject:event];
                }
            }
            [self.tableView reloadData];
        }];
    } else {
        [self fetchData];
    }
}

- (void)getCurrentLocation {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            self.user.location = geoPoint;
        }
    }];
}

#pragma mark - MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"PlacePin"];
    
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PlacePin"];
    }
    
    pin.canShowCallout = YES;
    pin.pinTintColor = [UIColor redColor];
    
    return pin;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.localEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    
    Event *event = [self.localEvents objectAtIndex:indexPath.row];
    
    //cell.eventLabel =  event.title
    //cell.eventImageView = event.image;
    //cell.distanceLabel.text = event.distance;
    
    return cell;
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"tableViewSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        EventInfoViewController *vc = segue.destinationViewController;
        vc.event = self.localEvents[indexPath.row];
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

@end