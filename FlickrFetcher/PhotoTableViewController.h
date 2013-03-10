//
//  PhotoTableViewController.h
//  FlickrFetcher
//
//  Created by SunnyUp on 13-3-10.
//  Copyright (c) 2013年 SunnyUp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSDictionary *place;
@end
