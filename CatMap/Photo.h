//
//  Photo.h
//  CatMap
//
//  Created by Jose on 27/1/18.
//  Copyright © 2018 Jose. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface Photo : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString* title;
@property (nonatomic) NSString* iD;
@property (nonatomic) NSNumber* latitude;
@property (nonatomic) NSNumber* longitude;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSURL* url;
@property (nonatomic) UIImage* image;

@end
