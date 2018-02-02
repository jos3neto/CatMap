//
//  DetailController.m
//  CatMap
//
//  Created by Jose on 31/1/18.
//  Copyright © 2018 Jose. All rights reserved.
//

#import "DetailController.h"
#import <MapKit/MapKit.h>

@interface DetailController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@end

@implementation DetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.delegate = self;
    [_mapView addAnnotation:_photo];
    _mapView.region = MKCoordinateRegionMakeWithDistance(_photo.coordinate, 300000, 300000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nullable MKAnnotationView*) mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation;
{
    // Try to dequeue an existing pin view first.
    MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    
    if (!pinView)
    {
        // If an existing pin view was not available, create one.
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        pinView.pinTintColor = [UIColor purpleColor];
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    }
    else { pinView.annotation = annotation; }
    
    return pinView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
