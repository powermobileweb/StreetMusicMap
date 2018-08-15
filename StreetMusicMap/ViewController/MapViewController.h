//
//  MapViewController.h
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/23/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "KMLParser.h"
#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController  <UIWebViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate > {
    KMLParser *kmlParser;
    CLLocationManager *locationManager;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeIndicator;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
