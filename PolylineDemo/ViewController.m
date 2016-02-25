//
//  ViewController.m
//  PolylineDemo
//
//  Created by Lin Zhang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize points = _points;
@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize locationManager = locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    locationManager=[[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [locationManager requestWhenInUseAuthorization];
    }
    CLLocation *location =[locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    currentLongitude = coordinate.longitude;
    currentLatitude = coordinate.latitude;
    [self configureLocationManager];
    */
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    MKMapCamera *newCamera=[[MKMapCamera alloc] init];
    [newCamera setAltitude:2500.0];
    [self.mapView setCamera:newCamera animated:YES];
    [self.view addSubview:self.mapView];
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                      longitude:userLocation.coordinate.longitude];
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    if (_points.count > 0) {
        CLLocationDistance distance = [location distanceFromLocation:_currentLocation];
        if (distance < 1)
            return;
    }
    if (nil == _points) {
        _points = [[NSMutableArray alloc] init];
    }
    [_points addObject:location];
    _currentLocation = location;
    [self configureRoutes];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 10, 10);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.mapView.showsUserLocation = YES;
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayView* overlayView = nil;
    if(overlay == self.routeLine)
    {
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 30;
        overlayView = self.routeLineView;
    }
    return overlayView;
}
- (void)configureRoutes
{
    MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f);
    MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f);
    MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    for(int idx = 0; idx < _points.count; idx++)
    {
        CLLocation *location = [_points objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        if (idx == 0) {
            northEastPoint = point;
            southWestPoint = point;
        } else {
            if (point.x > northEastPoint.x)
                northEastPoint.x = point.x;
            if(point.y > northEastPoint.y)
                northEastPoint.y = point.y;
            if (point.x < southWestPoint.x)
                southWestPoint.x = point.x;
            if (point.y < southWestPoint.y)
                southWestPoint.y = point.y;
        }
        pointArray[idx] = point;
    }
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    self.routeLine = [MKPolyline polylineWithPoints:pointArray count:_points.count];
    if (nil != self.routeLine) {
        [self.mapView addOverlay:self.routeLine];
    }
    free(pointArray);
    double width = northEastPoint.x - southWestPoint.x;
    double height = northEastPoint.y - southWestPoint.y;
    _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);
    [self.mapView setVisibleMapRect:_routeRect];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mapView = nil;
    self.routeLine = nil;
    self.routeLineView = nil;
}
@end