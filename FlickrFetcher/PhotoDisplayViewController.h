//
//  PhotoDisplayViewController.h
//  FlickrFetcher
//
//  Created by SunnyUp on 13-3-12.
//  Copyright (c) 2013年 SunnyUp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDisplayViewController : UIViewController
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
- (void)refresh;
@end
