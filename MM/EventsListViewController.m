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
#import "MM-Swift.h"

@interface EventsListViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) BOOL didInputLocation;
@property (nonatomic) NSString *currentPostalCode;
@property (nonatomic) NSMutableArray *localEvents;
@property (nonatomic) NSArray *sortedLocalEvents;
@property (nonatomic) NSMutableArray *localEventLocations;
@property (weak, nonatomic) IBOutlet UISearchBar *searchTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) User *user;

@end

@implementation EventsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.localEvents = [NSMutableArray new];
    self.sortedLocalEvents = [NSArray new];
    self.localEventLocations = [NSMutableArray new];
    
    self.mapView.delegate = self;
    self.searchTextField.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    self.user = (User*)[PFUser currentUser];
    
    [self getCurrentLocation];
    
    self.didInputLocation = NO;
    
    [self fetchData:self.user.location];
}

#pragma mark - Actions (buttons)

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.didInputLocation = YES;
    self.currentPostalCode = self.searchTextField.text;
    [self.locationManager stopUpdatingLocation];
    
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    
    [geo geocodeAddressString:self.searchTextField.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        self.lastLocation = placemarks[0].location;
        
        PFGeoPoint *geoPoint = [PFGeoPoint new];
        geoPoint.latitude = self.lastLocation.coordinate.latitude;
        geoPoint.longitude = self.lastLocation.coordinate.longitude;
        
        [self fetchData:geoPoint];
        
        LocationAnnotation *inputLocation = [[LocationAnnotation alloc] init];
        inputLocation.coordinate = self.lastLocation.coordinate;
        [self.mapView addAnnotation:inputLocation];
    }];
    
    [self.searchTextField resignFirstResponder];
    
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
                [self fetchData:self.user.location];
                
            }];
        }
    }
    
    self.lastLocation = currentLocation;
}

- (void)fetchData:(PFGeoPoint*)searchLocation {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    if(self.user.location != nil) {
        [query whereKey:@"location" nearGeoPoint:searchLocation];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [self.localEvents removeAllObjects];
            for (Event *event in objects) {
                if(self.user.location != nil) {
                    event.distance = [event.location distanceInKilometersTo:self.user.location];
                    
                    // convert event location from pfgeopoint to cllocation
                    double lat = event.location.latitude;
                    double lon = event.location.longitude;
                    
                    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                
                    [self.localEventLocations addObject:eventLocation];
                    [self.localEvents addObject:event];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.tableView reloadData];
                
                self.searchTextField.text = self.currentPostalCode;
                
                NSArray *tempArray = [[NSArray alloc] initWithArray:self.localEventLocations];
                [self.mapView addAnnotations:tempArray];
                
                NSSortDescriptor *sortByDistance = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
                self.sortedLocalEvents = [self.localEvents sortedArrayUsingDescriptors:@[sortByDistance]];
                
                MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
                MKCoordinateRegion region = MKCoordinateRegionMake(self.lastLocation.coordinate, span);
                [self.mapView setRegion:region animated:YES];
                
                });
        }];
        
    } else {
        
        //[self fetchData:searchLocation];
        
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
    
    if ([annotation isKindOfClass:[LocationAnnotation class]]) {
        pin.pinTintColor = [UIColor blueColor];
        pin.canShowCallout = NO;
    } else {
        pin.pinTintColor = [UIColor redColor];
        pin.canShowCallout = NO;
    }

    return pin;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.localEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    cell.imageView.image = nil;
    
    Event *event = [self.localEvents objectAtIndex:indexPath.row];
    
    [self getImageFor:event block:^(UIImage *image) {
        EventsListTableViewCell *crazyCell = [tableView cellForRowAtIndexPath:indexPath];
        crazyCell.eventImageView.image = image;
    }];
    
    cell.eventTitleLabel.text =  event.title;
    cell.eventDistanceLabel.text = [NSString stringWithFormat:@"%0.2f km", event.distance];
    
    return cell;
}

- (void)getImageFor:(Event*)event block:(void (^)(UIImage *image))completionBlock{
    PFQuery *query = [Event query];
    
    [query whereKey:@"title" equalTo:event.title];
    
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

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showEventDetail" sender:self];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showEventDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        EventInfoViewController *vc = segue.destinationViewController;
        vc.event = self.localEvents[indexPath.row];
    }
}

@end