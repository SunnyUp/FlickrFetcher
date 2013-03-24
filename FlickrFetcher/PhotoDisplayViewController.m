//
//  PhotoDisplayViewController.m
//  FlickrFetcher
//
//  Created by SunnyUp on 13-3-12.
//  Copyright (c) 2013年 SunnyUp. All rights reserved.
//

#import "FlickrFetcherAppDelegate.h"
#import "PhotoDisplayViewController.h"
#import "FlickrFetcher.h"

@interface PhotoDisplayViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation PhotoDisplayViewController

//@synthesize imageURL = _imageURL;
@synthesize photo = _photo;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if(_splitViewBarButtonItem != splitViewBarButtonItem)
    {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if(_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if(splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}
//
//- (void)setImageURL:(NSURL *)imageURL
//{
//    if(_imageURL != imageURL)
//    {
//        _imageURL = imageURL;
//        [self refresh];
//    }
//}

- (void)setPhoto:(NSDictionary *)photo
{
    if(_photo != photo)
    {
        _photo = photo;
        [self refresh];
    }
}

- (NSData *)imageData:(NSDictionary *)photo
{
    FlickrFetcherAppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSDictionary *cacheTable = app.cacleTable;
    NSString *photoID = [photo objectForKey:FLICKR_PHOTO_ID];
    NSURL *imageURL = [cacheTable objectForKey:photoID];
    if(imageURL == nil)
        imageURL = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    if(![imageURL isFileURL])
    {
        //to cache the image data
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSArray *urls = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        NSURL *cacheURL = [urls objectAtIndex:0];
        cacheURL = [cacheURL URLByAppendingPathComponent:photoID];
        cacheURL = [cacheURL URLByAppendingPathExtension:@"jpg"];
        [imageData writeToURL:cacheURL atomically:YES];
        
        NSMutableDictionary *vCacheTable = [cacheTable mutableCopy];
        [vCacheTable setObject:cacheURL forKey:photoID];
        app.cacleTable = [vCacheTable copy];
    }
    
    return imageData;
}

- (void)refresh
{
    if(self.scrollView)
    {        
        [self.spinner startAnimating];
        FlickrFetcherAppDelegate *app = [[UIApplication sharedApplication] delegate];
        app.nNetworkActivityCount++;
        NSDictionary *photo = self.photo;
        dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Image Downloader", NULL);
        dispatch_async(downloadQueue, ^{
            //TODO: trying to stop the download queue while the downloading image is not interested by the user
            NSData *imageData = [self imageData:self.photo];
            UIImage *image = [UIImage imageWithData:imageData];
            if(photo == self.photo)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(image)
                    {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                    }
                    
                    [self.spinner stopAnimating];
                    app.nNetworkActivityCount--;
                });
            }
        });
        //        dispatch_release(downloadQueue);
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.delegate = self;
    [self refresh];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"List";
    self.splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}

@end
