//
//  MapViewController.m
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/23/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()



@end


@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    
     [locationManager requestWhenInUseAuthorization];
    self.mapView.delegate = self;
    locationManager.delegate = self;
   
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoHeader"]];
    
    self.mapView.rotateEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    
    
    [self.loader startAnimating];
    
     NSString *path = [[NSBundle mainBundle] pathForResource:@"StreetMusicMap" ofType:@"kml"];
    NSURL *urlKML = [NSURL fileURLWithPath:path];
    kmlParser = [[KMLParser alloc] initWithURL:urlKML];
    [kmlParser parseKML];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [kmlParser points];
    [self.mapView addAnnotations:annotations];

    
    [self performSelectorInBackground:@selector(addPinsOnMap) withObject:nil];

}

-(void) addPinsOnMap {
    
    //MAP
    
    // Locate the path to the route.kml file in the application's bundle
    // and parse it with the KMLParser.
    // NSString *path = [[NSBundle mainBundle] pathForResource:@"StreetMusicMap" ofType:@"kml"];
    NSURL *urlKML = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/2788733/StreetMusicMap.kml"];
    kmlParser = [[KMLParser alloc] initWithURL:urlKML];
    [kmlParser parseKML];
    
    
//remove all
    NSMutableArray * annotationsToRemove = [self.mapView.annotations mutableCopy];
    [annotationsToRemove removeObject:self.mapView.userLocation];
    [self.mapView removeAnnotations:annotationsToRemove];
    
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [kmlParser points];
    [self.mapView addAnnotations:annotations];
    
    
    [self.loader stopAnimating];
    self.mapView.rotateEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    
  //  [self.mapView reloadInputViews];
    [locationManager startUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ) {
        self.mapView.showsUserLocation = YES;

        [self.mapView setCenterCoordinate:locationManager.location.coordinate]; //CLLocationCoordinate2DMake(0, 0)]; //
        self.mapView.camera.altitude = pow( 4.2, 11);
    }
    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    [locationManager stopUpdatingLocation];
    [self.mapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
    self.mapView.camera.altitude = pow( 4.19, 11);
}






@end
