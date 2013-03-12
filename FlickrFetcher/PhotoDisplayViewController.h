//
//  PhotoDisplayViewController.h
//  FlickrFetcher
//
//  Created by SunnyUp on 13-3-12.
//  Copyright (c) 2013年 SunnyUp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDisplayViewController : UIViewController
@property (nonatomic, strong) NSDictionary *photo;

- (void)refresh;
@end
