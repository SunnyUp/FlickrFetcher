//
//  PhotoDisplayViewController.m
//  FlickrFetcher
//
//  Created by SunnyUp on 13-3-12.
//  Copyright (c) 2013年 SunnyUp. All rights reserved.
//

#import "PhotoDisplayViewController.h"
#import "FlickrFetcher.h"

@interface PhotoDisplayViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation PhotoDisplayViewController

@synthesize photo = _photo;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)refresh
{
    if(self.photo)
    {
        self.navigationItem.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Image Downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSURL *imageUrl = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
            NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = nil;
                self.imageView.image = image;
                
                self.scrollView.contentSize = image.size;
                self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            });
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

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
