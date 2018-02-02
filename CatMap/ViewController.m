//
//  ViewController.m
//  CatMap
//
//  Created by Jose on 26/1/18.
//  Copyright © 2018 Jose. All rights reserved.
//

#import "ViewController.h"
#import "Photo.h"
#import "CustomCell.h"
#import "DetailController.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property NSMutableArray* photoArray;
@property NSURLSession* session;
@property int geoBlockCounter;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
#pragma mark - URL for first networking task, variable name "task", and session setup
    
    NSURL* url = [NSURL URLWithString:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=3cece1a974a69c3dcb6e908887eb87a9&tags=kitten,cat&tag_mode=all&sort=interestingness-desc&has_geo=1&extras=url_m&per_page=12"];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
#pragma mark - Completion block for geo networking task, variable name "geoTask"
    
    void (^geoBlock)(NSData*, NSURLResponse*, NSError*) = ^(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        
        NSError* convertError = nil;
        NSDictionary* metaDataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&convertError];
        
        if (convertError)
        {
            NSLog(@"JSON Error: %@", convertError);
            return;
        }
        
        //Set lat and long properties on photo object
        if (_geoBlockCounter < _photoArray.count)
        {
            ((Photo*)_photoArray[_geoBlockCounter]).latitude = metaDataDic[@"photo"][@"location"][@"latitude"];
            ((Photo*)_photoArray[_geoBlockCounter]).longitude = metaDataDic[@"photo"][@"location"][@"longitude"];
            ((Photo*)_photoArray[_geoBlockCounter]).coordinate = CLLocationCoordinate2DMake(((Photo*)_photoArray[_geoBlockCounter]).latitude.doubleValue, ((Photo*)_photoArray[_geoBlockCounter]).longitude.doubleValue);
            //NSLog(@"%f", ((Photo*)_photoArray[_geoBlockCounter]).coordinate.latitude);
            _geoBlockCounter += 1;
        }
    };
    
#pragma mark - Completion block for first networking task, variable name "task"
    
    void (^photoArrayBlock)(NSData*, NSURLResponse*, NSError*) = ^(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        
        NSError* convertError = nil;
        NSDictionary* metaDataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&convertError];
        
        if (convertError)
        {
            NSLog(@"JSON Error: %@", convertError);
            return;
        }
        
        NSArray* metaDataArray = metaDataDic[@"photos"][@"photo"];
        _photoArray = [NSMutableArray new];
        
        for (int i=0; i < metaDataArray.count; i++)
        {
            Photo* photo = [Photo new];
            photo.title = metaDataArray[i][@"title"];
            photo.iD = metaDataArray[i][@"id"];
            photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg",metaDataArray[i][@"farm"],metaDataArray[i][@"server"],metaDataArray[i][@"id"],metaDataArray[i][@"secret"]]];
            [_photoArray addObject:photo];
            //NSLog(@"%@",((Photo*)_photoArray[i]).url);
        }
        
        //geoTask nested in first networking task block
        //this is to serialize async API tasks
        for (int i=0; i < _photoArray.count; i++)
        {
            
            NSURL* geoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=3cece1a974a69c3dcb6e908887eb87a9&photo_id=%@&format=json&nojsoncallback=1", ((Photo*)_photoArray[i]).iD]];
        
            NSURLSessionDataTask* geoTask = [_session dataTaskWithURL:geoUrl completionHandler:geoBlock];
            
            [geoTask resume];
        }
        
        //Download the images and set .image property
        for (int i=0; i < _photoArray.count; i++)
        {
            ((Photo*)_photoArray[i]).image = [UIImage imageWithData:[NSData dataWithContentsOfURL:((Photo*)_photoArray[i]).url]];
        }
        
        //Next block necessary to update _photoArray between background queue and main queue
        //Because block is a closure, creates a copy of _photoArray
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [_collectionView reloadData];
         } ];
    };

#pragma mark - First data task call
    
    NSURLSessionDataTask* task = [_session dataTaskWithURL:url completionHandler:photoArrayBlock];
    [task resume];
    
}

#pragma mark - Collection view data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (__kindof UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    Photo* photo = _photoArray[indexPath.item];
    cell.imageView.image = photo.image;
    return cell;
}

#pragma mark - Flow layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat picDimension = (self.collectionView.frame.size.width) * 0.45;
    return CGSizeMake(picDimension, picDimension);
}

#pragma mark - Prepare for segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UICollectionViewCell*)sender
{
    if ([segue.identifier isEqualToString:@"detailSegue"])
    {
        DetailController* detailController = [segue destinationViewController];
        detailController.photo = _photoArray[[_collectionView indexPathForCell:sender].item];
    }
}

#pragma mark - Collection view delegate

/*- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"detailSegue" sender:[collectionView cellForItemAtIndexPath:indexPath]];
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
