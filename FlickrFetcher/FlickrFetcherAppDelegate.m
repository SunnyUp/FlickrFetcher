//
//  FlickrFetcherAppDelegate.m
//  FlickrFetcher
//
//  Created by SunnyUp on 13-3-8.
//  Copyright (c) 2013年 SunnyUp. All rights reserved.
//

#import "FlickrFetcherAppDelegate.h"

@implementation FlickrFetcherAppDelegate

@synthesize nNetworkActivityCount = _nNetworkActivityCount;
@synthesize cacleTable = _cacleTable;

- (void)setNNetworkActivityCount:(NSInteger)nNetworkActivityCount
{
    if(_nNetworkActivityCount != nNetworkActivityCount)
    {
        if(_nNetworkActivityCount && !nNetworkActivityCount)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        else if(!_nNetworkActivityCount && nNetworkActivityCount)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        _nNetworkActivityCount = nNetworkActivityCount;
   }
}

- (void)loadCacheTable
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheURL = [urls objectAtIndex:0];
    NSString *cachePath = [cacheURL path];
    NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:cachePath error:nil];
    NSMutableDictionary *vCacheTable = [[NSMutableDictionary alloc] init];
    for (NSString *filePath in cacheFiles) {
        NSString *photoID = [filePath stringByDeletingPathExtension];
        NSURL *fileURL = [cacheURL URLByAppendingPathComponent:filePath];
        [vCacheTable setObject:fileURL forKey:photoID];
    }
    self.cacleTable = [vCacheTable copy];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self loadCacheTable];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
